--일천의 환영검
local s,id=GetID()
function s.initial_effect(c)
	--묘지로 보내질 경우 소멸
	cyan.SemiTokenAttribute(c)
	--전사족 몬스터에만 장착 가능
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR))
	--①: 공격력 300 상승
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
end
