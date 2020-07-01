cd ../tests/PKSim.Tests/Data
for /r %%i in (*.pksim5) do git update-index --no-assume-unchanged %%i
