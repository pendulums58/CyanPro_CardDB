--마음을 굳힌 미스틸테인
local s,id=GetID()
function s.initial_effect(c)
	--①: 2000 LP 지불하고 1장 드로우
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	cyan.JustDraw(e1,1)
	c:RegisterEffect(e1)
	--②: 필드에서 묘지로 보내진 이 카드를 제외하고 3000 LP 회복 + 1장 드로우 (묘지로 보내진 턴 발동 불가)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
return aux.exccon(e) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,3000)
Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
if Duel.Recover(tp,3000,REASON_EFFECT)>0 then
Duel.Draw(tp,1,REASON_EFFECT)
end
end
