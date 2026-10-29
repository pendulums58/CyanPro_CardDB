CELESTIA_NUMBER=101268013

function Card.GetCelestiaNumber(c)
	local val=0
	for i,pe in ipairs({c:IsHasEffect(CELESTIA_NUMBER)}) do
		if pe:GetValue() then val=pe:GetValue() end
	end
	return val
end