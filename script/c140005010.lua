--돌관하는 환영검
local s,id=GetID()
function s.initial_effect(c)
	--①: 자신 환영검 카드 1장과 상대 카드 2장 파괴 + 어드민 조건부 자가 패 회수
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SETCARD_ILLUSIONSWORD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,c)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,3,0,0)
end
function s.adfilter(c)
	if not c:IsFaceup() or not c:IsType(TYPE_ACCESS) then return false end
	local ad=c:GetAdmin()
	return ad and ad:IsSetCard(SETCARD_ILLUSIONSWORD)
end
function s.cfilter(c)
	return c:IsSetCard(SETCARD_ILLUSIONSWORD) and c:IsDiscardable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		if c:IsRelateToEffect(e) and c:IsAbleToHand()
			and Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,2,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			if Duel.DiscardHand(tp,s.cfilter,2,2,REASON_EFFECT+REASON_DISCARD)==2 then
				c:CancelToGrave()
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end
