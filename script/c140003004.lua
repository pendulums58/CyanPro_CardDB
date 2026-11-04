--내가도와줘 토끼
local s,id=GetID()
function s.initial_effect(c)
	--페어링 소환
	cyan.AddPairingProcedure(c,s.pfilter,s.mfilter,1,1)
	c:EnableReviveLimit()
	
	--1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--페어링 소재
function s.pfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.mfilter(c,pair)
	return c:IsRace(RACE_BEAST) and pair:GetLevel()>0 and c:IsLevel(pair:GetLevel())
end

--1번 효과
function s.cntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x301)
end
function s.count(tp)
	return Duel.GetMatchingGroupCount(s.cntfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)+2
end
function s.thfilter(c)
	return c:IsSetCard(0x301) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x301) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selfilter(c,e,tp,ft)
	return s.thfilter(c) or (ft>0 and s.spfilter(c,e,tp))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=s.count(tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=s.count(tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:IsExists(s.selfilter,1,nil,e,tp,ft) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=g:FilterSelect(tp,s.selfilter,1,1,nil,e,tp,ft):GetFirst()
		local b1=s.thfilter(tc)
		local b2=ft>0 and s.spfilter(tc,e,tp)
		local op=0
		if b1 and b2 then op=Duel.SelectOption(tp,573,1152)
		elseif b2 then op=1 end
		Duel.DisableShuffleCheck()
		if op==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleHand(tp)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.ShuffleDeck(tp)
end
