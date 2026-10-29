--전생의 유언
local s,id=GetID()
function s.initial_effect(c)
	--내성 부여
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--동명 특수 소환
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsType(TYPE_MONSTER) and (chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE)) and chkc:IsControler(tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,e:GetHandler(),TYPE_MONSTER) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,e:GetHandler(),TYPE_MONSTER)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local op=0
		if tc:IsLocation(LOCATION_ONFIELD) then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		end
		if op==0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVING)
			e1:SetCondition(s.discon)
			e1:SetCountLimit(1)
			e1:SetOperation(s.disop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			Duel.RegisterEffect(e1,tp)				
		end
		if op==1 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCountLimit(1)
			e1:SetValue(s.valcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)==0 or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(tc)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():GetPreviousControler()==tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,tc) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp,tc)
	return c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local des=eg:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,des)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end