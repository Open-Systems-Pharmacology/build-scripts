require 'xmlsimple'

module SmartXls
  def self.update_smart_xls(source_dir, smart_xls_package, sx_version)
    #unzip smart xls and replace SX.dll in target dir
    unzip_dir = File.dirname(smart_xls_package)
    command_line = %W[e #{smart_xls_package} -o#{unzip_dir}]
    Utils.run_cmd('7z', command_line)
    copy_depdencies unzip_dir, source_dir do
      copy_file 'SX.dll'
    end

    update_sx_assembly_binding source_dir, sx_version
  end

  def self.update_sx_assembly_binding(source_dir, sx_version)
    Dir.glob(File.join(source_dir,'**', '*.exe.config')).each do |f|
      app_config = XmlSimple.xml_in(f, 'KeepRoot' => true)
      sx = app_config['configuration'][0]['runtime'][0]['assemblyBinding'][0]['dependentAssembly'].select {|node| node['assemblyIdentity'][0]['name']=='SX'}.first
      unless sx.nil?
        puts "Patching SmartXLS to #{sx_version} in #{f}".green
        sx['bindingRedirect'][0]['newVersion'] = sx_version
        File.open(f, 'w'){ |file|
          file.write("<?xml version='1.0' encoding='utf-8'?>\n")
          file.write(XmlSimple.xml_out app_config, 'KeepRoot' => true)
        }
      end
    end
  end  
end
