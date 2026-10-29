EFFECT_RAIMEI_IM=56260111
--뇌명용

local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)	
	--뇌명 효과 변경
	--기본 효과에 다리 적용중인 경우 자신을 대상으로 할수도 있도록 변경한다
	if code==56260110 and mt.eff_ct[c][0]==e then
		e:SetTarget(cyan.raimeitg)
	end
end
function cyan.raimeitg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local tcp=1-tp
	
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101262001) 
		and Duel.SelectYesNo(tp,aux.Stringid(101262001,0)) then
		tcp=(tp)
	end
	Duel.SetTargetPlayer(tcp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tcp,300)
end