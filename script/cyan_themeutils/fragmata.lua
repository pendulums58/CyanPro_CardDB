--플래그마타용



--공통 효과(어차피 다 같음)을 땜빵치기
--2번 링크 효과, 3번 패매수로 버려지면 특소 효과는 턴제약이 없으니 할만한데??


function cyan.AddFragmataEffect(c)
	local code=c:GetCode()
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(code,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(cyan.linkcost)
	e3:SetCondition(cyan.linkcondition)
	e3:SetTarget(cyan.linktarget)
	e3:SetOperation(cyan.linkoperation)
	c:RegisterEffect(e3)
	--패매수 공통효과
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(code,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(cyan.spcondition)
	e4:SetTarget(cyan.sptarget)
	e4:SetOperation(cyan.spoperation)
	c:RegisterEffect(e4)
end
function cyan.linkcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
function cyan.linktarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cyan.linkoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),c)
	end
end
function cyan.linkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local code=c:GetCode()
	if chk==0 then return c:GetFlagEffect(code)==0 end
	c:RegisterFlagEffect(code,RESET_CHAIN,0,1)
end
function cyan.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and bit.band(r,REASON_ADJUST)~=0
end
function cyan.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cyan.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end


function Duel.DecreaseMaxHandSize(c,p,ct)
	local val=6
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(p,EFFECT_HAND_LIMIT)}) do
		if val>pe:GetValue() then
			pe:SetValue(pe:GetValue()-ct)
		end
	end
end