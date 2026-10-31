--재로 빚은 검은 별
local s,id=GetID()
function c140000010.initial_effect(c)
	--rank up or dumping
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and (Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,c,e,tp,c,c:GetRank()+1) or Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
end
function s.spfilter(c,e,tp,mc,rn)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsXyzSummonable() and c:IsRank(rn)
end
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsAbleToGrave()
end
function s.xyzfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsXyzMonster() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)<1 then return end
	local fg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	local gg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local b1=#fg>0
	local b2=#gg>0
	if not (b1 or b2) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		local mc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
		if not mc then return end
		Duel.HintSelection(mc)
		if mc:IsImmuneToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc,mc:GetRank()+1):GetFirst()
		if xyz then
			xyz:SetMaterial(mc)
			Duel.Overlay(xyz,mc)
			Duel.BreakEffect()
			if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				xyz:CompleteProcedure()
			end
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
