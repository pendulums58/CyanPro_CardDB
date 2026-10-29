

-- 한정해제 유틸

--한정해제 효과 개조
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)	
	if code==65450690 then
		e:SetCountLimit(999)
		e:SetCost(cyan.fgcost)
		e:SetTarget(cyan.fgtg)
		e:SetOperation(cyan.fgop)
	end

end
function Card.IsRitualMonster(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL)
end
function cyan.fgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsPlayerAffectedByEffect(tp,101252003)
		or Duel.GetFlagEffect(tp,65450690)==0) and Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
	Duel.RegisterFlagEffect(tp,65450690,RESET_PHASE+PHASE_END,0,1)
end
function cyan.fgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND
	if Duel.IsPlayerAffectedByEffect(tp,101252000) then loc=loc+LOCATION_DECK end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c65450690.filter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,loc)
end
function cyan.fgop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND
	if Duel.IsPlayerAffectedByEffect(tp,101252000) then loc=loc+LOCATION_DECK end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c65450690.filter,tp,loc,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)
		--Cannot attack
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(65450690,RESET_EVENT+RESETS_STANDARD,0,1)
		--Destroy it during end phase
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c65450690.descon)
		e2:SetOperation(c65450690.desop)
		Duel.RegisterEffect(e2,tp)
	end
end

pcall(dofile,"repositories/delta-puppet/script/proc_ritual.lua")