--스타게이저
local s,id=GetID()
function s.initial_effect(c)
	--서치
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	cyan.JustSearch(e1,LOCATION_DECK,s.thfilter,1)
	c:RegisterEffect(e1)
end
function s.thfilter(c,ct)
	local tp=c:GetControler()
	local lv=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,id)+ct
	return c:IsLevel(lv)
end
