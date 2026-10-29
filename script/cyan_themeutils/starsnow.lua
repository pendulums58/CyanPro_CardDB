
--성설용 성설의 반짝임 개조 함수

local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)
	--성설의 반짝임
	if code==89181369 then
		e:SetTarget(cyan.sltarget)
		e:SetOperation(cyan.sloperation)
	end	
end

function cyan.slfilter(c,e,tp,rg)
	if not (c:IsType(TYPE_SYNCHRO) or Duel.IsPlayerAffectedByEffect(c:GetControler(),89181371)) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if not (c:IsRace(RACE_DRAGON) or Duel.IsPlayerAffectedByEffect(c:GetControler(),89181369)) then return false end
	if rg:IsContains(c) then
		rg:RemoveCard(c)
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
		rg:AddCard(c)
	else
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
	end
	return result
end

function cyan.sltarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then
		local loc=0
		if Duel.IsPlayerAffectedByEffect(c:GetControler(),89181370) then loc=LOCATION_GRAVE end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,loc,nil)
		return Duel.IsExistingTarget(cyan.slfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,rg)
	end
	local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cyan.slfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cyan.sloperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	local loc=0
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),89181370) then loc=LOCATION_GRAVE end
	local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,loc,nil)
	rg:RemoveCard(tc)
	if rg:CheckWithSumEqual(Card.GetLevel,tc:GetLevel(),1,99) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rm=rg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,99)
		Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		if rm:IsExists(Card.IsControler,1,nil,1-tp) then
			local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ONFIELD,0,nil,101216016)
			if g:GetCount()>1 then g=g:Select(tp,1,1,nil) end
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end