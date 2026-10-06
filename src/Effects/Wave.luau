--!strict
local WaveEffect = {}

function WaveEffect.getOffset(index: number, time: number): (number, number)
	-- continuous sine wave driven by real-time `time` (os.clock())
	local waveSize = math.sin((time * 5.5) + (index * 0.45)) * 1.8
	local waveTrans = (math.sin((time * 4.0) + (index * 0.30)) + 1) * 0.08

	return waveSize, waveTrans
end

return WaveEffect