--잔불여우 유틸
TOKEN_EMBERFOX=111330010

--토큰 소환 체크
function Cyan.EmberTokenCheck(tp)
	return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EMBERFOX,0,TYPES_TOKEN,200,200,1,RACE_PYRO,ATTRIBUTE_FIRE)
end
ember_token_codes={111330010,111330011,111330012,111330013,111330014,111330015,111330016}
function Cyan.CreateEmberToken(tp)
	--	math.randomseed(os.time())
		code=ember_token_codes[Duel.GetRandomNumber(1,#ember_token_codes)]
	return Duel.CreateToken(tp,code)
end
function Cyan.AddEmberTokenAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(Cyan.EmberTokenDestroy)
	c:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2,true)
end
function Cyan.EmberTokenDestroy(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsControler,1,nil,tp) and not eg:IsContains(e:GetHandler()) then Duel.Destroy(e:GetHandler(),REASON_EFFECT) end
end