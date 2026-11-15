--파이널 파이어워크
local s,id=GetID()
function s.initial_effect(c)
	--전체 파괴
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetAttack())
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)	
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end