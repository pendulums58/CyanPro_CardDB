--프레자일 필링
local s,id=GetID()
function s.initial_effect(c)
	--발동
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.plfilter(c,tp)
	return c:IsCode(140004006) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if sc then
		if Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_FZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,140004003,0,TYPES_TOKEN,1000,0,2,RACE_ROCK,ATTRIBUTE_WATER)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local token=Duel.CreateToken(tp,140004003)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.PlaceFieldSpell(sc:GetFirst(),tp)
		end	
	end
end
function s.sfilter(c)
	return c:IsFaceup() and c:IsCode(140004006)
end