--결속 효과
EVENT_MANEUVER=111900000


function Duel.Maneuver(e,c,r)
	Duel.RaiseEvent(c,EVENT_MANEUVER,e,r,e:GetHandlerPlayer(),e:GetHandlerPlayer(),0)
	Duel.RaiseSingleEvent(c,EVENT_MANEUVER,e,r,e:GetHandlerPlayer(),e:GetHandlerPlayer(),0)
	return 1
end
