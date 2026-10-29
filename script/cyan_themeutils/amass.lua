--축적 (버림받은 카드군) 효과
EVENT_AMASS=101270000


function Duel.Amass(e,val)
	local val1=0
	local tp=e:GetHandlerPlayer()
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,101270000) then
		if Duel.IsPlayerCanSpecialSummonMonster(tp,101270000,0,0x4011,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,101270000)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			if Duel.IsPlayerAffectedByEffect(tp,101270011) then
				local le={Duel.IsPlayerAffectedByEffect(tp,101270011)}
				for _,te in pairs(le) do
					if te then val1=te:GetValue() end
				end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(val1)
				token:RegisterEffect(e1)
			end
		else
			return
		end	
	end

	local tc=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,101270000):GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(val)
	tc:RegisterEffect(e1)
	-- if Duel.IsPlayerAffectedByEffect(tp,101270011) then	
		-- Duel.RegisterFlagEffect(tp,101270010,0,0,val)
	-- end
	local le={Duel.IsPlayerAffectedByEffect(tp,101270011)}
	for _,te in pairs(le) do
		if te then te:SetValue(te:GetValue()+val) end
	end
	Duel.RaiseEvent(e:GetHandler(),EVENT_AMASS,e,REASON_EFFECT,tp,tp,val)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_AMASS,e,REASON_EFFECT,tp,tp,val)	
end


--버림받은 자들의 도시 ①번 효과
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local cd=e:GetCode()
	if cd==40 or cd==41 or cd==42 or cd==47 or cd==71 then
		local con=e:GetCondition()
		if con==nil then e:SetCondition(cyan.lostcon)
		else
			e:SetCondition(cyan.lostcon2(con))
		end
		
	end
	
	cregeff(c,e,forced,...)
end
function cyan.lostcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetControler()
	return not Duel.IsPlayerAffectedByEffect(tp,101270003)
end
function cyan.lostcon2(con)
	return
		function(e,tp,eg,ep,ev,re,r,rp)
			if type(con)=="function" then
				if not tp then tp=e:GetHandler():GetControler() end
				return con(e,tp,eg,ep,ev,re,r,rp) and not Duel.IsPlayerAffectedByEffect(tp,101270003)
			else
				return not Duel.IsPlayerAffectedByEffect(tp,101270003)
			end
		end
end
function Duel.AmassCheck(tp)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,101270000) then
		return true
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,101270000,0,0x4011,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK)
	end
end
function Card.AmassCard(c,chk)
	return c.AmassEffect==true
end