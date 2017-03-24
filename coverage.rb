require_relative 'utils'

module Coverage
  def self.cover(filter, targetProjects)
    testProjects = Dir.glob("tests/**/*.csproj").select{|path| targetProjects.include?(File.basename path)}
    openCover = Dir.glob("packages/OpenCover.*/tools/OpenCover.Console.exe").first
    targetArgs = testProjects.join(" ")

    Utils.run_cmd(openCover, ["-register:user", "-target:nunit3-console.exe", "-targetargs:#{targetArgs}", "-output:OpenCover.xml", "-filter:#{filter}", "-excludebyfile:*.Designer.cs"])
    Utils.run_cmd("codecov", ["-f", "OpenCover.xml"])
  end
end