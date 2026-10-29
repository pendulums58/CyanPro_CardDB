

-- 신비용 유틸


-- 공통 효과 등록.
-- ty가 효과 몬스터면 전투 / 효과 파괴 내성, 액세스 몬스터면 효과 받지 않음
function cyan.AddHaloEffect(c,ty)
	if ty==TYPE_EFFECT then
		local e=Effect.CreateEffect(c)
		e:SetCondition(cyan.halocon)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(LOCATION_MZONE)
		e:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e:SetValue(1)
		c:RegisterEffect(e)
		local e1=e:Clone()
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e1)		
	end
	if ty==TYPE_ACCESS then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(cyan.halocon)
		e2:SetValue(cyan.efilter)
		c:RegisterEffect(e2)	
	end
end

function cyan.halocon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetColumnGroup():IsExists(Card.IsControler,1,nil,1-tp)
end
function cyan.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end