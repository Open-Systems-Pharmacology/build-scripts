require_relative 'utils'

task :cover, [:filter] do |task, args|
	coveralls = Dir.glob("packages/coveralls.net.*/tools/csmacnz.coveralls.exe").first
	testProjects = Dir.glob("tests/*.Tests/*.Tests.csproj")
	openCover = Dir.glob("packages/OpenCover.*/tools/OpenCover.Console.exe").first

	targetArgs = testProjects.join(" ")

	puts args.filter

#	Utils.run_cmd(openCover, ["-register:user", "-target:nunit3-console.exe", "-targetargs:#{targetArgs}", "-output:OpenCover.xml", "-filter:#{args.filter}", "-excludebyfile:*\*Designer.cs"])

	Utils.run_cmd(coveralls, ["--opencover", "-i", "OpenCover.xml", "--useRelativePaths", "--commitId", "$env:APPVEYOR_REPO_COMMIT", "--commitBranch", "env:APPVEYOR_REPO_BRANCH", "--commitAuthor", "$env:APPVEYOR_REPO_COMMIT_AUTHOR", "--commitEmail", "$env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL", "--commitMessage", "$env:APPVEYOR_REPO_COMMIT_MESSAGE", "--jobId", "$env:APPVEYOR_BUILD_NUMBER", "--serviceName", "appveyor"])
end

__END__

$testFilter = $args[ 0 ]
targetArgs = "$testProj /config:Debug"

If ($testFilter)
{
	$targetArgs = "$targetArgs  --where=$testFilter"
}


& $openCover -register:user -target:nunit3-console.exe -targetargs:$targetArgs -filter:$testFilter -output:OpenCover.xml
$env:APPVEYOR_BUILD_NUMBER
& $coveralls --opencover -i OpenCover.xml --repoToken $env:COVERALLS_REPO_TOKEN --useRelativePaths --commitId $env:APPVEYOR_REPO_COMMIT --commitBranch $env:APPVEYOR_REPO_BRANCH --commitAuthor $env:APPVEYOR_REPO_COMMIT_AUTHOR --commitEmail $env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL --commitMessage $env:APPVEYOR_REPO_COMMIT_MESSAGE --jobId $env:APPVEYOR_BUILD_NUMBER --serviceName appveyor