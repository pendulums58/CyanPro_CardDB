
EFFECT_DILE_CHANGE=101299999
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,f,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,f,...)
	--패스트 이미지
	if code==50292967 then
		e:SetOperation(cyan.piop)
	
	end
	--퓨처 비전
	if code==87902575 and mt.eff_ct[c][2]==e then
		e:SetOperation(cyan.fvretop)
	end
	
end


function cyan.piop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(cyan.retop)
		Duel.RegisterEffect(e1,tp)
	end
end

function cyan.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DILE_CHANGE) then
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)	
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_CONTROL)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(cyan.ctl)
		tc:RegisterEffect(e3)		
	else
		Duel.ReturnToField(e:GetLabelObject())
	end
	
end


function cyan.fvretop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetTurnPlayer()
	local lg=e:GetLabelObject():GetLabelObject()
	local g=lg:Filter(c87902575.retfilter,nil,e:GetHandler(),p)
	lg:Sub(g)
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if g:GetCount()>ft then
		local sg=g
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(87902575,2))
		g=g:Select(p,ft,ft,nil)
		sg:Sub(g)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	local tc=g:GetFirst()
	while tc do
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DILE_CHANGE) then
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)	
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_CONTROL)
			e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(cyan.ctl)
			tc:RegisterEffect(e3)			
		else
			Duel.ReturnToField(tc,POS_FACEUP_ATTACK)
		end
		
		tc=g:GetNext()
	end
end
function cyan.ctl(e,c)
	return e:GetHandlerPlayer()
end