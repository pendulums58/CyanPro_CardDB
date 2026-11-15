--심해로의 곤두박질
local s,id=GetID()
function s.initial_effect(c)
	--덤핑
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	cyan.JustDump(e1,1,1,Card.IsType,TYPE_MONSTER,Card.IsAttribute,ATTRIBUTE_WATER)
	c:RegisterEffect(e1)	
end
