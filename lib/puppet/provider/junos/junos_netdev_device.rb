##### ---------------------------------------------------------------
##### NetdevJunos - there will be only one of these objects 
##### during the puppet agent run.  The new object is triggered
##### by any of the Providers initailzing and creating a 
##### NetdevJunosResource object (next class...)
##### ---------------------------------------------------------------

module NetdevJunos
  
  class Device
    
    attr_accessor :netconf, :ready
    
    def initialize( catalog_version )
      
      @catalog_version = catalog_version
      @edits_count = 0
      @ready = false      
      
      fqdn = Facter.value(:fqdn)       
      Puppet::Transaction.on_transaction_done = self.method(:commit)      

      NetdevJunos::Log.debug "Opening a local connection: #{fqdn}"  
      @netconf = Netconf::IOProc.new
      @netconf.instance_variable_set :@trans_timeout, nil
      
      # --- assuming caller is doing exception handling around this!
      @netconf.open          
      
      begin 
        locked = @netconf.rpc.lock_configuration         
      rescue Netconf::RpcError => e 
        errmsg = e.to_s
        NetdevJunos::Log.err errmsg
      else
        @ready = true
      end         
      
    end
    
    def edit_config( jcfg_obj )      
      edits = Netconf::JunosConfig.new(:TOP)
      edits << jcfg_obj
      
      load_config = edits.doc.root      
      
      NetdevJunos::Log.debug load_config.to_xml, :tags => [:config, :changes]
      
      # if there is an RPC error (syntax error), it will generate an exception, and 
      # we want that to "bubble-up" to the calling context so don't 
      # rescue it here.  
      
      begin
        @netconf.rpc.load_configuration( load_config, :action => 'replace' )              
      rescue Netconf::RpcError => e
        # the load_configuration may yeield rpc-errors that are in fact not errors, 
        # but merely warnings.  Check for that here.
        unless e.rsp.xpath('//rpc-error[error-severity = "error"]').empty?
          NetdevJunos::Log.err "ERROR: load-configuration\n" + e.rsp.to_xml, :tags => [:config, :fail]
        else
          @edits_count += 1;
        end
      else
        @edits_count += 1;      
      end
    end

    ###
    ### Commit the candidate configuration, invoked by
    ### the 'on transaction complete' hooked in by junos_parent.rb
    ###
    
    def commit

      NetdevJunos::Log.debug "Checking for changes to commit for catalog #{@catalog_version}"    
      
      if @edits_count > 0 
                
        NetdevJunos::Log.info "Committing #{@edits_count} changes.", :tags => [:config, :commit]                 
                
        begin                
          report_show_compare          
          @netconf.rpc.commit_configuration( :log => "Puppet agent catalog: #{@catalog_version}" )                    
        rescue Netconf::RpcError => e
          NetdevJunos::Log.err "ERROR: Configuration change\n" + e.rsp.to_xml, :tags => [:config, :fail]
        else
          NetdevJunos::Log.notice "OK: COMMIT success!", :tags => [:config, :success]
        ensure
          @netconf.rpc.unlock_configuration                   
        end        
      end # -- committing changes
     
      NetdevJunos::Log.debug "Closing NETCONF connection"
      begin
        @netconf.close
      rescue
        # ignore - could be in a prior locked condition, and the call to close
        # currently raises an RPC error.
      end
      
    end  
    
    def report_show_compare
      args = { :database=>'candidate', :compare=>'rollback', :rollback=>'0', :format=>'text' }
      compare_rsp = @netconf.rpc.get_configuration( args )
      diff = "\n" + compare_rsp.xpath('//configuration-output').text   
      NetdevJunos::Log.notice( diff, :tags => [:config, :changes] )
    end
    
  end #--class
end #-- module

