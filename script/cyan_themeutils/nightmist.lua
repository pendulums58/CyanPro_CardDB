

--밤안개 메인몹 소생 공통 효과

function cyan.nightmisteffect(c)	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,c:GetCode())
	e2:SetCondition(cyan.nightmistcon)
	e2:SetTarget(cyan.nightmisttg)
	e2:SetOperation(cyan.nightmistop)
	c:RegisterEffect(e2)	
	local e3=e2:Clone()
	e3:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
function cyan.nmlinkcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x628) and c:IsType(TYPE_LINK)
end
function cyan.nightmistcheckzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(cyan.nmlinkcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function cyan.nightmistcon(e,tp,eg,ep,ev,re,r,rp)
	return 1-tp==Duel.GetTurnPlayer()
end
function cyan.nightmisttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=cyan.nightmistcheckzone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and zone~=0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cyan.nightmistop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=cyan.nightmistcheckzone(tp)
	if zone~=0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end