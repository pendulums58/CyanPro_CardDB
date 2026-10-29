--벚꽃 유틸


--공통효과 (소환한 턴 종료시 자신 필드 밀기)
function cyan.AddSakuraEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(cyan.sakurareg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function cyan.sakurareg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOGRAVE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetCountLimit(1)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(cyan.sakuraop)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e0)	
end
function cyan.sakuraop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--부유벚꽃 개조
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)
	if code==62015408 and mt.eff_ct[c][0]==e then
		e:SetCondition(cyan.sakuracon)
	end	
end
function cyan.sakuracon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		or Duel.IsPlayerAffectedByEffect(c:GetControler(),103555011))
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_EXTRA,0,1,nil)
end