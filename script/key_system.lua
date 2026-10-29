--키 카드 관련 시스템
local function key_is_locked(e)
	return not e:GetHandler():IsType(TYPE_UNLOCKED)
end
local function key_sp_locked(e)
	return e:GetHandler():IsType(TYPE_UNLOCKED)
end
function cyan.AddLockedKeyAttribute(c,req)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(key_is_locked)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(key_sp_locked)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_MSET)
	e3:SetCondition(key_is_locked)
	c:RegisterEffect(e3)
end

function Effect.SetUnlock(e,code)
	e:SetTarget(cyan.UnlockTarget(code))
	e:SetOperation(cyan.UnlockOperation(code))
	e:SetValue(code)
	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
end

function cyan.UnlockTarget(code)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	end
end
function cyan.UnlockOperation(code)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
		local c=e:GetHandler()
		Debug.Message("KEY UNLOCK: before="..c:GetCode())
		c:Recreate(code, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil, true)
		Debug.Message("KEY UNLOCK: after="..c:GetCode())
		if Duel.SpecialSummon(c,SUMMON_TYPE_UNLOCK,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.RaiseSingleEvent(c,EVENT_KEY_UNLOCKED,e,0,tp,tp,0)
			Duel.RaiseEvent(c,EVENT_KEY_UNLOCKED,e,0,tp,tp,0)
		end
	end
end
function cyan.SetUnlockedEffect(c,func)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_KEY_UNLOCKED)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetOperation(func)
	c:RegisterEffect(e1)
end
