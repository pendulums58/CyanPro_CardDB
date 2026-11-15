--퐁!
local s,id=GetID()
function s.initial_effect(c)
	--①: 같은 이름의 카드 2장을 덱에서 묘지로 보내고 효과를 무효로 하여 자신 필드에 세트
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsChainDisablable(ev)
end
function s.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local code=re:GetHandler():GetCode()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,2,nil,code) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,2,2,nil,code)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		if not rc:IsRelateToEffect(re) then return false end
		if rc:IsType(TYPE_FIELD) then
			return rc:IsSSetable(true)
		else
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then
				ft=ft-1
			end
			return ft>0 and rc:IsSSetable(true)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsSSetable() then
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
		Duel.MoveToField(rc,tp,tp,rc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
