--지층에 묻히다
local s,id=GetID()
function s.initial_effect(c)
	--덱바운스
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetDefense())
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)	
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	local def=e:GetLabel()
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil,def)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)	
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToDeckAsCost()
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetDefense())
end
function s.filter(c,def)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (c:GetAttack()<def or c:GetDefense()<def) and c:IsMonster()
end