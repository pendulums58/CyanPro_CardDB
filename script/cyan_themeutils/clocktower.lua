
--시계탑용 유옥의 시계탑 개조 함수

local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)	
	--유옥의 시계탑
	--카운터의 숫자를 체크
	if code==75041269 and mt.eff_ct[c][3]==e then
		e:SetOperation(cyan.checkctop)
	end
	--카운터 쌓는 숫자 변경
	if code==75041269 and mt.eff_ct[c][1]==e then
		e:SetOperation(cyan.addctop)
		e:SetCondition(cyan.addccon)
	end
	--특수 소환 변경
	if code==75041269 and mt.eff_ct[c][4]==e then
		e:SetCondition(cyan.twsscon)
		e:SetTarget(cyan.twsstg)
		e:SetOperation(cyan.twssop)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_FZONE)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetCondition(cyan.twigcon)
		e1:SetTarget(cyan.twsstg)
		e1:SetCost(cyan.twigcost)
		e1:SetOperation(cyan.twssop1)
		e1:SetCountLimit(1,75041269)
		cregeff(c,e1)
	end
end

function cyan.checkctop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetCounter(0x1b))
end
function cyan.addctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(tp,101213306)
	e:GetHandler():AddCounter(0x1b,ct+1)
end
function cyan.twsscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsReason(REASON_DESTROY) then return false end
	if e:GetLabelObject():GetLabel()>=4 then return true end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213304) then return true end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213309) then return true end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),116000006) then return true end
	return false
end
function cyan.twigcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,101213319)
end
function cyan.twigcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=e:GetHandler():GetCounter(0x1b)
	local g=Duel.GetMatchingGroup(c75041269.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213304) then		
		local g1=Duel.GetMatchingGroup(cyan.clockssfilter,tp,LOCATION_EXTRA,0,nil,e,tp,ct)
		g:Merge(g1)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213309) then		
		local g2=Duel.GetMatchingGroup(cyan.clockssfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,ct)
		g:Merge(g2)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),116000006) then		
		local g3=Duel.GetMatchingGroup(cyan.clockssfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,ct)
		g:Merge(g3)
	end
	if chk==0 then return g:GetCount()>0 end
end
function cyan.addccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213312) then
		return true
	end
	return Duel.GetTurnPlayer()~=tp
end
function cyan.twsstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local loc=LOCATION_HAND+LOCATION_DECK
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213304) then
		loc=loc+LOCATION_EXTRA
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function cyan.twssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(c75041269.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213304) then		
		local g1=Duel.GetMatchingGroup(cyan.clockssfilter,tp,LOCATION_EXTRA,0,nil,e,tp,e:GetLabelObject():GetLabel())
		g:Merge(g1)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213309) then		
		local g2=Duel.GetMatchingGroup(cyan.clockssfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,e:GetLabelObject():GetLabel())
		g:Merge(g2)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),116000006) then		
		local g3=Duel.GetMatchingGroup(cyan.clockssfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,e:GetLabelObject():GetLabel())
		g:Merge(g3)
	end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	if not Duel.IsPlayerAffectedByEffect(c:GetControler(),101213328) then ct=1 end
	local g=g:Select(tp,1,ct,nil)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,1,tp,tp,false,false,POS_FACEUP)
	end
end
function cyan.twssop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetHandler():GetCounter(0x1b)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(c75041269.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213304) then		
		local g1=Duel.GetMatchingGroup(cyan.clockssfilter,tp,LOCATION_EXTRA,0,nil,e,tp,ct)
		g:Merge(g1)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101213309) then		
		local g2=Duel.GetMatchingGroup(cyan.clockssfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,ct)
		g:Merge(g2)
	end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),116000006) then		
		local g3=Duel.GetMatchingGroup(cyan.clockssfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,ct)
		g:Merge(g3)
	end
	if not c:IsRelateToEffect(e) then return end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	if not Duel.IsPlayerAffectedByEffect(c:GetControler(),101213328) then ct=1 end
	local g=g:Select(tp,1,ct,nil)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,1,tp,tp,false,false,POS_FACEUP)
	end
end
function cyan.clockssfilter(c,e,tp,lv)
	return c:IsSetCard(0x60a) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cyan.clockssfilter1(c,e,tp,lv)
	local sslv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then sslv=c:GetRank() end
	return c:IsSetCard(0x60a) and sslv>0 and sslv<=lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cyan.clockssfilter2(c,e,tp,lv)
	return c:IsSetCard(SETCARD_PHANTOMTHIEF) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end