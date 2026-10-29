CYAN_EFFECT_CANNOT_BE_ACCESS_MATERIAL=EFFECT_CANNOT_BE_ACCESS_MATERIAL
CYAN_EFFECT_ACCESS_LEVEL=EFFECT_ACCESS_LEVEL
CYAN_EFFECT_ACCESS_ATTACK=EFFECT_ACCESS_ATTACK
CYAN_EFFECT_CANNOT_BE_ADMIN=EFFECT_CANNOT_BE_ADMIN
ALREADY_HIJJACKED=EFFECT_HIJACK_USED
EFFECT_CANNOT_HIJJACK=EFFECT_CANNOT_HIJACK
EFFECT_HIIJACK_ACCESS=EFFECT_HIJACK_ACCESS
ADDITIONAL_HIIJACK=EFFECT_ADDITIONAL_HIJACK

local ov=Duel.Overlay
function Duel.Overlay(xc,mt)
	if xc:IsType(TYPE_ACCESS) and xc:GetAdmin() then
		if type(mt)=="Group" then
			Duel.SendtoGrave(mt,REASON_RULE)
		else
			Duel.SendtoGrave(mt,REASON_RULE)
		end
		return
	end
	return ov(xc,mt)
end
-- function Duel.Overlay(xc,mt)
	-- if xc:IsType(TYPE_ACCESS) then
		-- if xc:GetAdmin() then
			-- Duel.SendtoGrave(mt,REASON_RULE)
		-- else
			-- if type(mt)=="Group" then
				-- if mt:GetCount()>1 then
					-- local ad=mt:GetFirst()
					-- mt:Sub(ad)
					-- Duel.SendtoGrave(mt,REASON_RULE)
					-- mt=ad
				-- end
			-- end
		-- end
	-- else
		-- if type(mt)=="Group" then
			-- local tc=mt:GetFirst()
			-- while tc do
				-- if tc:IsType(TYPE_ACCESS) then
					-- local ad=tc:GetAdmin()
					-- if ad then Duel.SendtoGrave(ad,REASON_RULE) end
				-- end
				-- tc=mt:GetNext()
			-- end
		-- else
			-- if mt:IsType(TYPE_ACCESS) then
				-- local ad=mt:GetAdmin()
				-- Duel.SendtoGrave(ad,REASON_RULE)
			-- end
		-- end
	-- end
	-- return ov(xc,mt)
-- end
function Duel.AdminOverlay(xc,mt)
	if type(mt)=="Group" then
		local tc=mt:GetFirst()
		while tc do
			if tc:IsType(TYPE_ACCESS) then
				local ad=tc:GetAdmin()
				ov(xc,ad)
			end
			tc=mt:GetNext()
		end
	else
		if mt:IsType(TYPE_ACCESS) then
			local ad=mt:GetAdmin()
			Duel.SendtoGrave(ad,REASON_RULE)
			ov(xc,ad)
		end
	end
	return ov(xc,mt)	
end
function Card.IsCanBeAccessMaterial(c,acc)
	if c:IsForbidden() then
		return false 
	end
	local le={c:IsHasEffect(CYAN_EFFECT_CANNOT_BE_ACCESS_MATERIAL)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f==1 then return false end
		if f and f(te,acc) then return false end
	end
	return true
end
function cyan.IsCanBeAccessMaterial(c,acc)
	return Card.IsCanBeAccessMaterial(c,acc)
end
function Duel.SetAdmin(acc,ad,e)
	if not acc:IsType(TYPE_ACCESS) then return false end
	local res=ad:SetAdmin(acc)
	if not res then return false end
	local tp=acc:GetControler()
	Duel.RaiseEvent(acc,EVENT_GET_ADMIN,e,0,tp,tp,0)
	Duel.RaiseSingleEvent(acc,EVENT_GET_ADMIN,e,0,tp,tp,0)
end
function cyan.IsCanBeAdmin(c,acc)
	if c:IsType(TYPE_TOKEN) then return false end
	local le={c:IsHasEffect(CYAN_EFFECT_CANNOT_BE_ADMIN)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f==1 then return false end
		if f and f(te,acc) then return false end
	end
	return true
end
function Auxiliary.acclimit(e,se,sp,st)
	return st&SUMMON_TYPE_ACCESS==SUMMON_TYPE_ACCESS
end
function Duel.AccessSummon(tp,mt,ac)

end
function cyan.nacon(e)
	local ad=e:GetHandler():GetAdmin()
	return ad==nil
end
function cyan.adcon(e)
	local ad=e:GetHandler():GetAdmin()
	return ad~=nil
end
function Duel.DetachAdmin()


end
--�׼��� ��ȯ
function cyan.AddAccessProcedure(c,f1,f2,f3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(SUMMON_TYPE_ACCESS)
	e1:SetCondition(cyan.AccessCondition(f1,f2,f3))
	e1:SetOperation(cyan.AccessOperation(f1,f2,f3))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cyan.scomp)
	e2:SetOperation(cyan.scompop)
	c:RegisterEffect(e2)
end
function cyan.scomp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_ACCESS
end
function cyan.scompop(e,tp,eg,ep,ev,re,r,rp)
end
function cyan.NoLevelFilter(c)
	return not (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK))
end
function cyan.AccessFilter1(c,ac,f1,f2,f3,tp)
	if f1(c) and c:IsFaceup() and cyan.IsCanBeAccessMaterial(c,ac) then
		local mg=Group.CreateGroup()
		if c:GetAccessAttack(ac)>ac:GetAttack()
			or c:GetAttack()>ac:GetAttack() then
			local g1=Duel.GetMatchingGroup(cyan.AccessFilter2,tp,LOCATION_MZONE,0,c,ac,f2)
			mg:Merge(g1)
		end
		if c:GetAccessAttack(ac)<ac:GetAttack()
			or c:GetAttack()<ac:GetAttack()	then
			local g2=Duel.GetMatchingGroup(cyan.AccessFilter3,tp,LOCATION_MZONE,0,c,ac,f2)
			mg:Merge(g2)
		end
		if not c:IsType(TYPE_LINK+TYPE_XYZ) then
			if c:GetAccessLevel(ac)>ac:GetLevel() 
				or c:GetLevel()>ac:GetLevel() then
				local g3=Duel.GetMatchingGroup(cyan.AccessFilter4,tp,LOCATION_MZONE,0,c,ac,f2)				
			mg:Merge(g3)
			end
			if c:GetAccessLevel(ac)<ac:GetLevel() 
				or c:GetLevel()<ac:GetLevel()then
				local g4=Duel.GetMatchingGroup(cyan.AccessFilter5,tp,LOCATION_MZONE,0,c,ac,f2)
				mg:Merge(g4)
			end
		end
		if not cyan.IsCanBeAdmin(c,ac) then
			mg=mg:Filter(cyan.AccessFilter6,nil)
		end
		mg=mg:Filter(cyan.IsCanBeAccessMaterial,nil,ac)
		if f3 ~=nil then mg=mg:Filter(f3,nil,c,ac) end
		if c:IsHasEffect(EFFECT_MUST_ADMIN) then mg=mg:Filter(cyan.mustacheck,nil) end
		return mg:GetCount()>0
	end
	return false
end
function cyan.mustacheck(c)
	return not c:IsHasEffect(EFFECT_MUST_ADMIN)
end
function cyan.AccessFilter2(c,ac,f)
	return f(c) and c:IsFaceup() 
		and (c:GetAccessAttack(ac)<ac:GetAttack() or c:GetAttack()<ac:GetAttack())
end
function cyan.AccessFilter3(c,ac,f)
	return f(c) and c:IsFaceup() 
		and (c:GetAccessAttack(ac)>ac:GetAttack() or c:GetAttack()>ac:GetAttack())
end
function cyan.AccessFilter4(c,ac,f)
	return f(c) and c:IsFaceup() 
		and (c:GetAccessLevel(ac)<ac:GetLevel() or c:GetLevel()<ac:GetLevel())
		and not c:IsType(TYPE_LINK+TYPE_XYZ)
end
function cyan.AccessFilter5(c,ac,f)
	return f(c) and c:IsFaceup() 
		and (c:GetAccessLevel(ac)>ac:GetLevel() or c:GetLevel()>ac:GetLevel())
		and not c:IsType(TYPE_LINK+TYPE_XYZ)	
end
function cyan.AccessFilter6(c,ac,f)
	return cyan.IsCanBeAdmin(c,ac)
end
function cyan.AccessCondition(f1,f2,f3)
	return
		function(e,c)
			if c==nil then
				return true
			end
			local tp=c:GetControler()
			if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_ACCESS,tp,false,false) then return false end
			return Duel.IsExistingMatchingCard(cyan.AccessFilter1,tp,LOCATION_MZONE,0,1,nil,c,f1,f2,f3,tp)
		end
end
function cyan.AccMaterialEvent(g,e,tp)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_ACCESS)
end
function cyan.HiiJackCheck(c,acc,hj,e)
	local tp=c:GetControler()
	local le={acc:IsHasEffect(EFFECT_CANNOT_HIJJACK)}
	for _,te in pairs(le) do
		if te then return false end
	end
	if Duel.IsPlayerAffectedByEffect(acc:GetControler(),EFFECT_CANNOT_HIJJACK) then
		return false
	end
	local le={c:IsHasEffect(EFFECT_HIIJACK_ACCESS)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and f(te,acc,hj) and cyan.IsCanBeAdmin(hj,acc) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_ACCESS,tp,false,false) then return true end
	end
	return false
end
function cyan.AccessOperation(f1,f2,f3)
	return
		function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
			local g=Duel.SelectMatchingCard(tp,cyan.AccessFilter1,tp,LOCATION_MZONE,0,0,1,nil,c,f1,f2,f3,tp)
			if g:GetCount()==0 then return end
			local tc=g:GetFirst()
			local mg=Group.CreateGroup()
			
			if tc:GetAccessAttack(c)>c:GetAttack()
				or tc:GetAttack()>c:GetAttack() then
				local g1=Duel.GetMatchingGroup(cyan.AccessFilter2,tp,LOCATION_MZONE,0,tc,c,f2)
				mg:Merge(g1)
				if f2(tc) then
					local g5=Duel.GetMatchingGroup(cyan.AccessFilter2,tp,LOCATION_MZONE,0,tc,c,f1)
					mg:Merge(g5)
				end
			end
			if tc:GetAccessAttack(c)<c:GetAttack() 
				or tc:GetAttack()<c:GetAttack()then
				local g2=Duel.GetMatchingGroup(cyan.AccessFilter3,tp,LOCATION_MZONE,0,tc,c,f2)
				mg:Merge(g2)
				if f2(tc) then
					local g6=Duel.GetMatchingGroup(cyan.AccessFilter3,tp,LOCATION_MZONE,0,tc,c,f1)
					mg:Merge(g6)
				end
			end
			if not c:IsType(TYPE_LINK+TYPE_XYZ) then
				if tc:GetAccessLevel(c)>c:GetLevel() 
					or tc:GetLevel()>c:GetLevel() then
					local g3=Duel.GetMatchingGroup(cyan.AccessFilter4,tp,LOCATION_MZONE,0,tc,c,f2)
					mg:Merge(g3)
					if f2(tc) then
						local g7=Duel.GetMatchingGroup(cyan.AccessFilter4,tp,LOCATION_MZONE,0,tc,c,f1)
						mg:Merge(g7)
					end
				end
				if tc:GetAccessLevel(c)<c:GetLevel()
					or tc:GetLevel()<c:GetLevel() then
					local g4=Duel.GetMatchingGroup(cyan.AccessFilter5,tp,LOCATION_MZONE,0,tc,c,f2)
					mg:Merge(g4)
					if f2(tc) then
						local g8=Duel.GetMatchingGroup(cyan.AccessFilter5,tp,LOCATION_MZONE,0,tc,c,f1)
						mg:Merge(g8)
					end
				end
			end
			if c:IsHasEffect(EFFECT_MUST_ADMIN) then mg=mg:Filter(cyan.mustacheck,nil) end
			if not cyan.IsCanBeAdmin(tc,c) then
				mg=mg:Filter(cyan.AccessFilter6,nil)
			end
			mg=mg:Filter(cyan.IsCanBeAccessMaterial,nil,c)
			if f3 ~=nil then mg=mg:Filter(f3,nil,tc,c) end
			local ag=mg:Select(tp,0,1,nil)
			if ag:GetCount()==0 then return end
			g:Merge(ag)
			g:KeepAlive()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sg1=g:Filter(cyan.AccessFilter6,nil)
			if sg1:IsExists(Card.IsHasEffect,1,nil,EFFECT_MUST_ADMIN) then
			sg1=sg1:Filter(Card.IsHasEffect,nil,EFFECT_MUST_ADMIN)
			end
			local xg=sg1:Select(tp,1,1,nil)
			local xc=xg:GetFirst()
			g:RemoveCard(xc)
			local mg2=xc:GetOverlayGroup()
			if xc:IsType(TYPE_XYZ) and mg2:GetCount()~=0 then
				Duel.SendtoGrave(mg2,REASON_RULE)
			end
			local mg3=xc:GetAdmin()
			if xc:IsType(TYPE_ACCESS) and mg3 then
				Duel.SendtoGrave(mg3,REASON_RULE)
			end
			local hiijackable=true
			if Duel.GetFlagEffect(tp,ALREADY_HIJJACKED)~=0 and Duel.GetFlagEffect(tp,ADDITIONAL_HIIJACK)==0 then
				hiijackable=false
			end
			if Duel.GetFlagEffect(tp,ALREADY_HIJJACKED)==2 then
				hiijackable=false
			end
			xc:SetAdmin(c)
			local hj=g:GetFirst()
			if Duel.IsExistingMatchingCard(cyan.HiiJackCheck,tp,LOCATION_EXTRA,0,1,nil,c,hj,e) 
				and hiijackable and Duel.SelectYesNo(tp,680) then
				local hacc=Duel.SelectMatchingCard(tp,cyan.HiiJackCheck,tp,LOCATION_EXTRA,0,1,1,nil,c,hj,e)
				if hacc:GetCount()>0 then
						local ha=hacc:GetFirst()
						local hmg=Group.CreateGroup()
						hmg:AddCard(hj)
						ha:SetMaterial(hmg)
						local mg4=hj:GetOverlayGroup()
						if hj:IsType(TYPE_XYZ) and mg4:GetCount()~=0 then
							Duel.SendtoGrave(mg4,REASON_RULE)
						end
						local mg5=hj:GetAdmin()
						if hj:IsType(TYPE_ACCESS) and mg5 then
							Duel.SendtoGrave(mg5,REASON_RULE)
						end
						hj:SetAdmin(ha)
						sg:AddCard(ha)
						if Duel.GetFlagEffect(tp,ALREADY_HIJJACKED)==1 and Duel.GetFlagEffect(tp,ADDITIONAL_HIIJACK)==1 then
							Duel.RegisterFlagEffect(tp,ALREADY_HIJJACKED,RESET_PHASE+PHASE_END,0,2)
						else
							Duel.RegisterFlagEffect(tp,ALREADY_HIJJACKED,RESET_PHASE+PHASE_END,0,1)
						end
						g:AddCard(xc)
						c:SetMaterial(g)
						g:RemoveCard(xc)
						g:RemoveCard(hj)
						g:DeleteGroup()
					else
						g:AddCard(xc)
						c:SetMaterial(g)
						g:RemoveCard(xc)
						cyan.AccMaterialEvent(g,e,tp)
						g:DeleteGroup()
					end
			else
				g:AddCard(xc)
				c:SetMaterial(g)
				g:RemoveCard(xc)
				cyan.AccMaterialEvent(g,e,tp)
				g:DeleteGroup()
			end
			
			sg:AddCard(c)
			-- Duel.SendtoGrave(g,REASON_MATERIAL+REASON_ACCESS)
			-- local tc=g:GetFirst()
			-- while tc do
				-- Duel.RaiseSingleEvent(tc,EVENT_BE_MATERIAL,e,REASON_ACCESS,tp,tp,0)
				-- tc=g:GetNext()
			-- end
			-- Duel.RaiseEvent(g,EVENT_BE_MATERIAL,e,REASON_ACCESS,tp,tp,0)
			-- g:DeleteGroup()
		end
end
   local itype=Card.IsType

	local covchk=Card.CheckRemoveOverlayCard
	cyan.CheckRemoveAdmin=function(c,tp,ct,r)
		if itype(c,TYPE_ACCESS) then
			return covchk(c,tp,ct,r)
		end
		return false
	end
	cyan.GetAdminCount=function(tp,s,o)
		local ct=0
		if s then
			local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
			local sc=sg:GetFirst()
			while sc do
				local sct=sc:GetAdmin()
				if sct then
					ct=ct+1
				end
				sc=sg:GetNext()
			end
		end
		if o then
			local og=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
			local oc=og:GetFirst()
			while oc do
				local oct=oc:GetAdmin()
				if oct then
					ct=ct+1
				end
				oc=og:GetNext()
			end
		end
		return ct
	end
	cyan.CheckRemoveAdminCount=function(tp,s,o,ct,r)
		return cyan.GetAdminCount(tp,s,o)>=ct
	end
	cyan.RemoveAdmin=function(tp,s,o,mi,ma,r)
		local mg=Group.CreateGroup()
		local g=Duel.GetMatchingGroup(Card.GetAdmin,tp,s*LOCATION_MZONE,o*LOCATION_MZONE,nil,tp,1,r)
			local tc=g:GetFirst()
			while tc do
				local sg=tc:GetAdmin()
				if sg then
					mg:AddCard(sg)
				end
				tc=g:GetNext()
			end
			local rm=mg:Select(tp,mi,ma,nil)
			return Duel.SendtoGrave(rm,r)
	end

