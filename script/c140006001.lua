--스토리텔러 - 황금의 시인
local s,id=GetID()
function s.initial_effect(c)
	--①: 패에서 지속 마법 카드 1장을 버리고 패에서 특수 소환 (룰 특소)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--②: ①의 효과로 특수 소환 성공 시 자신 필드의 지속 마법 카드 1장을 몬스터 취급으로 특수 소환
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.mspcon)
	e2:SetTarget(s.msptg)
	e2:SetOperation(s.mspop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsDiscardable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,c)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_DISCARD,nil,nil,true)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	g:DeleteGroup()
end
function s.mspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.mspfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),Duel.ReadCard(c,CARDDATA_SETCODE),TYPE_MONSTER+TYPE_EFFECT,500,500,3,RACE_FAIRY,ATTRIBUTE_LIGHT)
end
function s.msptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.mspfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.mspfilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.mspfilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.mspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),Duel.ReadCard(tc,CARDDATA_SETCODE),TYPE_MONSTER+TYPE_EFFECT,500,500,3,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		tc:AddStoryTellerAttribute(e:GetHandler())
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
