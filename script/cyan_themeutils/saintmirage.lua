--환성 공통효과
--장착 카드의 장착 조건을 무시
EFFECT_EQUIP_IGNORE=611

-- local cregeff=Card.RegisterEffect
-- function Card.RegisterEffect(c,e,forced,...)
	
	-- --미리 이 카드의 원래 장착의 Stringid 변경(expansions의 string을 업데이트)
	-- if e:GetType()==EFFECT_TYPE_ACTIVATE and bit.band(e:GetCategory(),CATEGORY_EQUIP)==CATEGORY_EQUIP then
		-- e:SetDescription(681)
	-- end
	
	-- --이 효과가 장착 제한이면 개조에 들어감
	-- if e:GetCode()==EFFECT_EQUIP_LIMIT then
		-- Debug.Message("eqlimit fix started")
		-- if c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP) and e:GetLabelObject()==nil then
		
			-- local egv=e:GetValue()
			-- e:SetValue(cyan.svalue(egv))
			-- --장착 제한이 있다 + LabelObject가 없다 = 성급한 매장류의 소생카드는 아니다.
			-- --즉 여기서 새로 saintchk를 목표로 잡는 장착을 만들어주면 OK	
			-- local e1=Effect.CreateEffect(c)
			-- e1:SetCategory(CATEGORY_EQUIP)
			-- e1:SetDescription(682)
			-- e1:SetType(EFFECT_TYPE_ACTIVATE)
			-- e1:SetCode(EVENT_FREE_CHAIN)
			-- e1:SetCondition(cyan.eqclcon)
			-- e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
			-- e1:SetTarget(cyan.sainttg)
			-- local av=c:GetActivateEffect()
			-- e1:SetLabelObject(av)
			-- if av then 
				-- av=av:GetOperation()
				-- e1:SetOperation(av)
			-- else
				-- e1:SetOperation(cyan.saintop)
			-- end
			-- cregeff(c,e1,forced,...)			
		-- end
	-- end
	-- cregeff(c,e,forced,...)
-- end
local aep=aux.AddEquipProcedure
function Auxiliary.AddEquipProcedure(c,p,f,eqlimit,cost,tg,op,con)
	f=cyan.neweqfun(f)
	return aep(c,p,f,eqlimit,cost,tg,op,con)
end
function cyan.neweqfun(f)
	return function(c,e,tp)
		return (f and f(c,e,tp)) or (not f) or cyan.saintchk(c)
	end
end
function cyan.svalue(egv)
	return function(e,c)
		return cyan.saintchk(c) or (egv and egv(e,c)) or not egv
	end
end
function cyan.eqclcon(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	return e1:CheckCountLimit(tp)
end
function cyan.saintchk(c)
	local le={c:IsHasEffect(EFFECT_EQUIP_IGNORE)}
	for _,te in pairs(le) do			
		local f1=te:GetValue()
		if type(f1)=="function" then f1=f1(te) end
		if f1 then 
		return true end
	end	
	return false
end
function cyan.saintfilter(c)
	return c:IsFaceup() and cyan.saintchk(c)
end
function cyan.sainttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cyan.saintfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cyan.saintfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,cyan.saintfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function cyan.saintop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

local cgec=Card.GetEquipCount
function Card.GetEquipCount(c)
	local tp=c:GetControler()
	if c:IsHasEffect(103551007) then
		local ct=Duel.GetMatchingGroupCount(cyan.eqfil,tp,LOCATION_ONFIELD,0,c,c)
		return ct+cgec(c)
	end
	return cgec(c)
end
local cgeg=Card.GetEquipGroup
function Card.GetEquipGroup(c)
	local tp=c:GetControler()
	local g=cgeg(c)
	if c:IsHasEffect(103551007) then
		local ct=Duel.GetMatchingGroup(cyan.eqfil,tp,LOCATION_ONFIELD,0,c,c)
		g:Merge(ct)
		return g
	end
	return cgeg(c)	
end
function cyan.eqfil(c,tc)
	local g=cgeg(tc)
	return not g:IsContains(c)
end