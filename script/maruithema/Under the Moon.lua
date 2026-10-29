EVENT_MOVED=101271009

--그 몬스터가 자리를 이동했을 때 격발함.
local dms=Duel.MoveSequence
function Duel.MoveSequence(tc,seq)
	dms(tc,seq)
	Duel.RaiseEvent(tc,EVENT_MOVED,e,REASON_EFFECT,tp,tp,0)
	Duel.RaiseSingleEvent(tc,EVENT_MOVED,e,REASON_EFFECT,tp,tp,0)
	return 
end

--몬스터가 자리를 스왑해도 이동했을 경우로 취급
local dss=Duel.SwapSequence
function Duel.SwapSequence(tc1,tc2)
	dss(tc1,tc2)
	Duel.RaiseEvent(tc1,EVENT_MOVED,e,REASON_EFFECT,tp,tp,0)
	Duel.RaiseSingleEvent(tc1,EVENT_MOVED,e,REASON_EFFECT,tp,tp,0)
	return 
end