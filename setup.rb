require 'securerandom'
require_relative 'utils'
require_relative 'wix'

namespace :setup do
	desc "Performs the required steps to create a setup"
	task :create, [:src_dir, :setup_dir, :deploy_dir, :product_name, :product_version, :harvest_ignored_files, :suite_name, :setup_files, :solution_dir, :manufacturer] do |task, args|
		@deploy_dir =  File.join(args.setup_dir, 'deploy');
		@harvest_dir = File.join(@deploy_dir, 'harvest');
		@product_version	= args.product_version
		@product_name	 = args.product_name	
		@manufacturer = args.manufacturer
		@suite_name = args.suite_name
		@harvest_ignored_files = args.harvest_ignored_files || []
		@setup_files = args.setup_files || []
		@solution_dir = args.solution_dir;

		create_deploy_dir
		copy_src_files args.src_dir
		
		harvest_app				

		copy_setup_files args.setup_files					
		Rake::Task['setup:create_setup'].invoke
	end

	desc "Creates the setup: requirement: all setup dependencies should have been copied to the deploy folder"
	task :create_setup => [:set_variables_for_setup, :run_light] 

	desc "Copy the files required to launch the setup in the deploy folder."
	task :set_variables_for_setup do
		@variables = {}
		@variables[:ProductId] = Utils.uuid.to_s
		@variables[:DeployDir] = @deploy_dir
		@variables[:SuiteName] = @suite_name
		@variables[:ProductName] =@product_name
		@variables[:ProductVersion] = @product_version
		@variables[:Manufacturer] = @manufacturer
		release_version_split= @product_version.split('.')
		release_version = "#{release_version_split[0]}.#{release_version_split[1]}"
		@variables[:ProductReleaseVersion] = release_version	
		@variables[:ProductFullName] = "#{@product_name} #{release_version}"
	end

	desc "Runs the candle executable as first step of the setup process"
	task :run_candle do 
		all_wxs = Dir.glob("#{@deploy_dir}/*.wxs")
		all_variables = @variables.each.collect do |k, v|
			"-d#{k}=#{v}"
		end
		all_options = %W[-ext WixUIExtension -ext WixNetFxExtension -o #{@deploy_dir}/]
		Utils.run_cmd(Wix.candle, all_wxs + all_variables + all_options)
	end

	desc "Runs the light command that actually creates the msi package"
	task :run_light => [:run_candle] do 
		all_wixobj = Dir.glob("#{@deploy_dir}/*.wixobj")
		all_options = %W[-o #{@deploy_dir}/#{@product_name}.#{@product_version}.msi -nologo -ext WixUIExtension -ext WixNetFxExtension -spdb -b #{@deploy_dir}/ -cultures:en-us]
		Utils.run_cmd(Wix.light, all_wixobj + all_options)
	end

private
	def harvest_app
		@harvest_ignored_files.each do |file|
			FileUtils.rm File.join(@harvest_dir, file)
		end

		Rake::Task[:heat].execute  OpenStruct.new(source_directory: @harvest_dir, component_name: 'App', output_dir:  @deploy_dir)
	end

	def create_deploy_dir
		FileUtils.rm_rf  @deploy_dir
		FileUtils.mkdir_p @deploy_dir
		FileUtils.mkdir_p @harvest_dir		  
	end

	def copy_src_files(src_dir)
		src_files = File.join(src_dir, '*.*')
		copy_to_deploy_dir src_files
		copy_to_target_dir src_files, @harvest_dir, %w[pdb, xml]
	end

	def copy_setup_files(setup_files)
		setup_files.each do |file|
			copy_to_deploy_dir File.join(@solution_dir, file)
		end
	end

	def copy_to_deploy_dir(source)
		copy_to_target_dir source, @deploy_dir
	end

	def copy_to_target_dir(source, target_dir, ignored_extensions=[])
		Dir.glob	source do |file|
			copy file, target_dir, verbose: false	unless file_should_be_ignored(file, ignored_extensions)
		end
	end

	def file_should_be_ignored(file, ignored_extensions)
		ignored_extensions.any? { |ext| file.include? ext  }
	end
end
