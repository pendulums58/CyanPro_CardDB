--집행자들 효과용 유틸

EFFECT_DOP_CONTROL=101299999

--상실집행자 도파민
--상대(1-tp)가 자신(tp)의 필드 카드를 대상으로 하는 경우, 상대(1-tp)의 필드도 대상 가능 + 자신이 고름


local dst=Duel.SelectTarget
function Duel.SelectTarget(selp,filter,tp,sloc,oloc,mn,mx,...)
	if Duel.IsPlayerAffectedByEffect(selp,EFFECT_DOP_CONTROL) 
	and	(bit.band(oloc,LOCATION_MZONE)==LOCATION_MZONE or bit.band(oloc,LOCATION_SZONE)==LOCATION_SZONE)then
		sloc=oloc
		selp=1-selp
	end
	return dst(selp,filter,tp,sloc,oloc,mn,mx,...)
end