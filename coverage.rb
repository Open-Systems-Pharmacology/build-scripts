require_relative 'utils'

task :cover, [:filter] do |task, args|
	coveralls = Dir.glob("packages/coveralls.net.*/tools/csmacnz.coveralls.exe").first
	testProjects = Dir.glob("tests/*.Tests/*.Tests.csproj")
	openCover = Dir.glob("packages/OpenCover.*/tools/OpenCover.Console.exe").first

	targetArgs = testProjects.join(" ")

	puts args.filter

	Utils.run_cmd(openCover, ["-register:user", "-target:nunit3-console.exe", "-targetargs:#{targetArgs}", "-output:OpenCover.xml", "-filter:#{args.filter}", "-excludebyfile:*.Designer.cs"])

	Utils.run_cmd(coveralls, ["--opencover", "-i", "OpenCover.xml", "--useRelativePaths", "--repoToken", ENV['COVERALLS_REPO_TOKEN'], "--commitId", ENV['APPVEYOR_REPO_COMMIT'], "--commitBranch", ENV['APPVEYOR_REPO_BRANCH'], "--commitAuthor", ENV['APPVEYOR_REPO_COMMIT_AUTHOR'], "--commitEmail", ENV['APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL'], "--commitMessage", ENV['APPVEYOR_REPO_COMMIT_MESSAGE'], "--jobId", ENV['APPVEYOR_BUILD_NUMBER'], "--serviceName", "appveyor"])
end