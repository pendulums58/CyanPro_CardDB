--내가도와줘 고양이
local s,id=GetID()
function s.initial_effect(c)
	--페어링 소환
	cyan.AddPairingProcedure(c,s.pfilter,s.mfilter,1,1)
	c:EnableReviveLimit()

	--1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
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
function s.costfilter(c)
	return c:IsSetCard(0x301) and c:IsDiscardable()
end
function s.pairingfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x301) and c:IsType(TYPE_PAIRING)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x301) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	local ct=#sg
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,sg,e,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pairingfilter,tp,LOCATION_MZONE,0,1,nil)
		and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DISCARD)
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	sg:KeepAlive()
	e:SetLabel(#sg)
	e:SetLabelObject(sg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local dg=e:GetLabelObject()
	local exg=dg and dg:Clone() or Group.CreateGroup()
	if dg then dg:DeleteGroup() e:SetLabelObject(nil) end
	if ct<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,exg,e,tp)
	if #g<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,ct,ct,nil)
	for tc in sg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
	end
	if Duel.SpecialSummonComplete()==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local pc=Duel.SelectMatchingCard(tp,s.pairingfilter,tp,LOCATION_MZONE,0,1,1,og):GetFirst()
	if not pc then return end
	Duel.HintSelection(pc)
	pc:SetPair(og)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Destroy(pc,REASON_EFFECT)
	end
end
