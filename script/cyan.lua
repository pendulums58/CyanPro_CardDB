--Cyan.lua_ver 2023/04/10_18:34


cyan=cyan or {}
Cyan=cyan
PI=50292967
FV=87902575

local dm=Debug.Message
RACE_SIXH=0x2000000

global_fusion_processing=false

function Card.IsOwner(c,p)
	return c:GetOwner()==p
end
--클라이언트 브로커 / SendtoHand 조작
local dsth=Duel.SendtoHand
function Duel.SendtoHand(c,p,r)
	local g=Group.CreateGroup()
	if type(c)=="Card" then
		g:AddCard(c)
	else
		g:Merge(c)
	end
	--덱에서 들어가는 카드 걸러내기
	local g1=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
	--각 플레이어별로 해당 효과를 적용할지를 처리
	local spg=g1:Filter(Card.IsOwner,nil,0)
	local spg1=cyan.brokerprocess(spg,p)
	g:Merge(spg1)	
	local opg=g1:Filter(Card.IsOwner,nil,1)
	local opg1=cyan.brokerprocess(opg,p)
	g:Merge(opg1)

	if spg1:GetCount()>0 then
		Duel.ConfirmCards(1,spg1)
	end
	if opg1:GetCount()>0 then
		Duel.ConfirmCards(0,opg1)
	end
	return dsth(g,p,r)
end
function cyan.brokerprocess(g,p)
	--들어온 g가 없으면 그대로 종료
	--최종적으로 추가된 카드는 g1이 된다
	local g1=Group.CreateGroup()
	if g:GetCount()==0 then return g1 end
	--g는 덱에서 패에 넣어지는 카드, p는 그것이 누구의 패에 들어갈지(nil로 원래 주인)
	local ow=g:GetFirst():GetOwner()
	if p==nil then p=ow end
	--주인과 패에 넣는 플레이어가 다르다면 그대로 종료
	if p~=ow then return g1 end
	--해당 플레이어가 효과를 받고 있는지를 체크 및, 효과를 적용할 수 있는지를 체크.
	if Duel.IsPlayerAffectedByEffect(p,111310081) 
		and Duel.IsExistingMatchingCard(cyan.brokercheck,p,LOCATION_DECK,0,1,nil,g)
		and Duel.SelectYesNo(p,aux.Stringid(111310081,0)) then
		--효과를 적용받을 수 있고, 그러기를 선택했다면 효과 처리
		local th=Duel.SelectMatchingCard(p,cyan.brokercheck,p,LOCATION_DECK,0,1,1,nil,g)
		if th:GetCount()>0 then
			g1:Merge(th)
			--처리했다면, 해당 플레이어에게 영향을 주는 카드 중 하나를 골라, 스택을 1 소모한다.
			local fg=Group.CreateGroup()
			for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(p,111310081)}) do
				fg:AddCard(pe:GetHandler())
			end
			local fc=nil
			if fg:GetCount()==1 then
				fc=fg:GetFirst()
			else
				fc=fg:Select(p,1,1,nil)
			end
			Duel.Hint(HINT_CARD,0,fc:GetCode())
			fc:RegisterFlagEffect(111310081,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
	return g1
end
function cyan.brokercheck(c,g)
	return c:IsAbleToHand() and g:IsExists(cyan.brokercheck2,1,nil,c)	
end
function cyan.brokercheck2(c,tc)
	return c:IsLevel(tc:GetLevel()) and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute()) and not c:IsCode(tc:GetCode())
end
function Card.IsCanBeFusionMaterialParareal(c)
	if c:IsStatus(STATUS_FORBIDDEN) then
		return false
	end
	if c:IsHasEffect(EFFECT_CANNOT_BE_FUSION_MATERIAL) then
		return false
	end
	if c:IsHasEffect(EFFECT_CANNOT_BE_MATERIAL) then
		return false
	end	
	-- if c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL) then
		-- local le={tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
		-- for _,te in pairs(le) do			
			-- local f1=te:GetValue()
			-- if type(f1)=="function" then f1=f1(te) end
			-- if f(te,tp) and val<f1 then
				-- val=f1
			-- end
		-- end		
	-- end
	return true
end

-- (구) IsSetCardList 함수
-- EFFECT_ALL_SETCARD 대응을 위해 card / number 패러미터를 card - card 패러미터로 변경
-- 구 코드의 경우 Additional_setcards와의 호환 오류 문제도 있었음.
-- function Card.IsSetCardList(c,setcode)
	-- local set=tonumber(setcode)
	-- local code=0
	-- if not set then return false end
	-- while set>0 do
		-- code=math.floor(set%0x10000)
		-- if c:IsSetCard(code) then return true end
		-- if c:IsHasEffect(EFFECT_ALL_SETCARD) then return true end
		-- set=math.floor(set/0x10000)
	-- end
	-- return false
-- end

-- function Card.IsNotSetCardList(c,setcode)
	-- local set=tonumber(setcode)
	-- local code=0
	-- if not set then return true end
	-- while set>0 do
		-- code=math.floor(set%0x10000)
		-- if c:IsSetCard(code) then return false end
		-- if c:IsHasEffect(EFFECT_ALL_SETCARD) then return false end
		-- set=math.floor(set/0x10000)
	-- end
	-- return true
-- end

function Card.IsSetCardList(c,tc)
	if type(tc) == "number" then
		Debug.Message("Using Old SetCardList Function. returned false as error exception.")
		return false
	end
	local set=c:GetSetCard()
	if set==nil then return false end
	while set>0 do
		code=math.floor(set%0x10000)
		if tc:IsSetCard(code) then return true end
		if tc:IsHasEffect(EFFECT_ALL_SETCARD) then return true end
		set=math.floor(set/0x10000)
	end	
	set=tc:GetSetCard()
	if set==nil then return false end
	while set>0 do
		code=math.floor(set%0x10000)
		if c:IsSetCard(code) then return true end
		if c:IsHasEffect(EFFECT_ALL_SETCARD) then return true end
		set=math.floor(set/0x10000)
	end		
	return false
end
function Card.IsNotSetCardList(c,tc)
	if type(tc) == "number" then
		Debug.Message("Using Old NotSetCardList Function. returned false as error exception.")
		return false
	end
	local set=c:GetSetCard()
	if set==nil then return true end
	while set>0 do
		code=math.floor(set%0x10000)
		if tc:IsSetCard(code) then return false end
		if tc:IsHasEffect(EFFECT_ALL_SETCARD) then return false end
		set=math.floor(set/0x10000)
	end	
	set=tc:GetSetCard()
	if set==nil then return true end
	while set>0 do
		code=math.floor(set%0x10000)
		if c:IsSetCard(code) then return false end
		if c:IsHasEffect(EFFECT_ALL_SETCARD) then return false end
		set=math.floor(set/0x10000)
	end		
	return true
end

local cisc=Card.IsSetCard
function Card.IsSetCard(c,sc)
	if c:IsHasEffect(EFFECT_ALL_SETCARD) then return true end
	return cisc(c,sc)
end
local dclc=Duel.CheckLPCost
function Duel.CheckLPCost(p,vl)
	if Duel.IsPlayerAffectedByEffect(p,101223030) then return dclc(p,vl*2) end
	return dclc(p,vl)
end
local dplc=Duel.PayLPCost
function Duel.PayLPCost(p,vl)
	if Duel.IsPlayerAffectedByEffect(p,101223030) then return dplc(p,vl*2) end
	return dplc(p,vl)	
end

--자주 쓰는 함수들
function Card.IsCreator(c)
	return c:IsSetCard(0x622) or c:IsSetCard(0x620) or c:IsSetCard(0xfe)
end

--카드 효과 개조하는 함수
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)
	--흑백의☆파동
	if code==31677606 then
		e:SetCondition(cyan.bwcon)
	end

	if code==80896940 and mt.eff_ct[c][4]==e then
		e:SetCondition(cyan.nircon)
	end
	local et=e:GetType()
	if et&EFFECT_TYPE_XMATERIAL==EFFECT_TYPE_XMATERIAL then
		local egc=e:GetCondition()
		if type(egc)=="function" then e:SetCondition(cyan.etxmcon(egc)) 
		else
			e:SetCondition(cyan.etxmcon(egc))
		end
	end	
	--긴급동조
	if code==94634433 and mt.eff_ct[c][0]==e then
        e:SetOperation(cyan.tuneop(e:GetOperation()))
    end


	if e:IsHasCategory(CATEGORY_FUSION_SUMMON) then
		e:SetTarget(cyan.fustg(e:GetTarget()))
		e:SetOperation(cyan.fusop(e:GetOperation()))
	end
		
end
function cyan.fustg(f)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		global_fusion_processing=true
		if chk==0 then
			local tf=f(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			global_fusion_processing=false
			return tf
		end
		
		global_fusion_processing=false
	end
end
function cyan.fusop(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		global_fusion_processing=true
		f(e,tp,eg,ep,ev,re,r,rp)
		global_fusion_processing=false
	end
end
function cyan.tuneop(op)
	return function(e,tp,eg,ep,ev,re,r,rp)
		op(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) 
			and Duel.IsPlayerAffectedByEffect(tp,101223218) and Duel.GetFlagEffect(tp,101223218)==0 then
			Duel.BreakEffect()
			c:CancelToGrave()
			Duel.ChangePosition(c,POS_FACEDOWN)
			Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			Duel.RegisterFlagEffect(tp,101223218,RESET_PHASE+PHASE_END,0,1)
		end	
	end
end
local dr=Duel.Recover
function Duel.Recover(tp,val,r)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		local le={tc:IsHasEffect(EFFECT_CHANGE_RECOVER)}
		for _,te in pairs(le) do			
			local f=te:GetTarget()
			local f1=te:GetValue()
			if type(f1)=="function" then f1=f1(te) end
			if f(te,tp) and val<f1 then
				val=f1
			end
		end
		tc=g:GetNext()
	end
	dr(tp,val,r)
	return val
end
function cyan.etxmcon(egc)
	return
		function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			if type(egc)=="function" then
				return egc(e,tp,eg,ep,ev,re,r,rp) and not c:IsType(TYPE_ACCESS)
			else
				return not c:IsType(TYPE_ACCESS)
			end
		end
end
function cyan.etacon(egc)
	return
		function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			if type(egc)=="function" then
				return egc(e,tp,eg,ep,ev,re,r,rp) and c:IsType(TYPE_ACCESS)
			else
				return c:IsType(TYPE_ACCESS)
			end
		end
end
function cyan.bwcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31677606.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		or Duel.IsPlayerAffectedByEffect(tp,101225018)
end

function cyan.addEastStyleEffect(c)
	local e=Effect.CreateEffect(c)
	e:SetCategory(CATEGORY_TOGRAVE)
	e:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_DELAY)
	-- e:SetCondition(cyan.esecon)
	e:SetCode(EVENT_REMOVE)
	e:SetTarget(cyan.esetg)
	e:SetOperation(cyan.eseop)
	c:RegisterEffect(e)
end
--세미토큰 효과
function cyan.SemiTokenAttribute(c)
	--묘지로 보내진 경우 소멸
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e:SetCode(EVENT_TO_GRAVE)
	e:SetOperation(cyan.semigraveop)
	c:RegisterEffect(e)
	local e1=e:Clone()
	e1:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e1)
end
function cyan.semigraveop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Exile(e:GetHandler(),REASON_RULE)
end
-- function cyan.esecon(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- return c:IsReason(REASON_EFFECT)
-- end
function cyan.esetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function cyan.eseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
	end
end
function cyan.nirvanaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lp=math.ceil(Duel.GetLP(1-tp)/2)
	Duel.SetLP(1-tp,lp)
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),101242002) then
		Duel.Recover(tp,lp,REASON_EFFECT)
	end
end
function cyan.nircon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetCondition() or (Duel.IsPlayerAffectedByEffect(c:GetControler(),101242009) and c:GetSummonType()==SUMMON_TYPE_PENDULUM)
end
local cit=Card.IsType
function Card.IsType(c,ty)
		if c:IsLocation(LOCATION_DECK) then
			local le={c:IsHasEffect(EFFECT_ADD_TYPE)}
			for _,te in pairs(le) do			
				local f1=te:GetValue()
				if type(f1)=="function" then f1=f1(te) end
				if bit.bor(ty,f1)==ty then 
				return true end
			end	
		end
		if c:IsCode(101253001) and c:IsLocation(LOCATION_OVERLAY) and bit.band(ty,TYPE_SYNCHRO)==TYPE_SYNCHRO then
			local tp=c:GetControler()
			local g=Duel.GetMatchingGroup(cit,0,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_XYZ)
			local tc=g:GetFirst()
			while tc do
				if tc:GetOverlayGroup():IsContains(c) and tc:GetOverlayCount()>1 then
					return true
				end
				tc=g:GetNext()
			end
			return false
		end
	return cit(c,ty)
end
local cgt=Card.GetType
function Card.GetType(c)

	local ty=cgt(c)
	if not c:IsLocation(LOCATION_DECK) then return ty end
	local mt=_G["c"..c:GetCode()]
	if mt and mt.eff_ct then
		if mt.eff_ct[c] and mt.eff_ct[c][0] then
			local tc=0
			while mt.eff_ct[c][tc] do
				local e=mt.eff_ct[c][tc]
				if e:GetCode()==EFFECT_ADD_TYPE and e:GetRange()==LOCATION_DECK then
					local f1=e:GetValue()
					if type(f1)=="function" then f1=f1(e) end
					ty=ty+f1
				end
				tc=tc+1
			end		
		end
	end 
	return ty	
end
-- function Card.GetType(c)
	-- local ty=cgt(c)
		-- local le={c:IsHasEffect(EFFECT_ADD_TYPE)}
		-- for _,te in pairs(le) do	
			-- local f1=te:GetValue()
			-- if type(f1)=="function" then f1=f1(te) end
			-- if c:IsLocation(te:GetRange()) then 
				-- ty=ty+f1 
				-- Debug.Message("ok")
			-- end
			-- Debug.Message("loc="..c:GetLocation()..", ran="..te:GetRange())
			-- ty=ty+f1
		-- end	
		-- Debug.Message("code"..c:GetCode()..", ty="..ty)
	-- return ty	
-- end
local cgc=Card.GetCode
function Card.GetCode(c)
	if cgc(c)==111310098 then return 111310014 end
	return cgc(c)
end

local cgoc=Card.GetOriginalCode
function Card.GetOriginalCode(c)
	if cgoc(c)==111310098 then return 111310014 end
	return cgoc(c)
end

local cic=Card.IsCode
function Card.IsCode(c,...)
	local code={...}
	if cgc(c)==111310098 then
		for i=1,#code do
			if code[i]==111310014 then
				return true
			end
		end
	end
	return cic(c,...)
end

local cioc=Card.IsOriginalCode
function Card.IsOriginalCode(c,...)
	local code={...}
	if cgoc(c)==111310098 then
		for i=1,#code do
			if code[i]==111310014 then
				return true
			end
		end
	end
	return cioc(c,...)
end

-- 효과 무효로부터 보호(몰?루 프레이어)
-- 효과 무효 (NegateActivation / NegateEffect 계통)에 간섭하여 해당 효과 무효를 처리하지 않은 후 CountLimit 소모


local dna=Duel.NegateActivation
function Duel.NegateActivation(v)
	local te=Duel.GetChainInfo(v,CHAININFO_TRIGGERING_EFFECT)
	local p=te:GetHandlerPlayer()
	local protect=false
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(p,EFFECT_PREVENT_NEGATION)}) do
		if not protect then
			protect=true
			pe:UseCountLimit(p,1)
		end
	end
	
	if protect then
		local dummy=Duel.SelectOption(p,aux.Stringid(101223182,0))
		local dummy=Duel.SelectOption(1-p,aux.Stringid(101223182,1))
		return 0
	else
		return dna(v)
	end
end

local dne=Duel.NegateEffect
function Duel.NegateEffect(v)
	local te=Duel.GetChainInfo(v,CHAININFO_TRIGGERING_EFFECT)
	local p=te:GetHandlerPlayer()
	local protect=false
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(p,EFFECT_PREVENT_NEGATION)}) do
		if not protect then
			protect=true
			pe:UseCountLimit(p,1)
		end
	end
	
	if protect then
		local dummy=Duel.SelectOption(p,aux.Stringid(101223182,0))
		local dummy=Duel.SelectOption(1-p,aux.Stringid(101223182,1))
		return 0
	else
		return dne(v)
	end
end




-- 상대 조종 효과 (상대가 고르는 / 대상으로 하는 효과의 선택권을 자신이 빼앗음)
-- 해당하는 함수들은 Select 계통 전반(SelectMatchingCard / SelectSubGroup / GetMatchingGroup + Group 계통의 Select 함수 전반)
-- 해당 플레이어가 효과를 받고 있으면, 해당 플레이어의 덱을 보는 효과를 그 반대 플레이어가 검열함 (tp에게 적용되고 있으면 tp가 사용하는 증원이 영향을 받음)
-- 해당 함수들의 매개변수 중 tp의 LOCATION을 입력받았을 때, LOCATION_DECK 내지는 LOCATION_GRAVE가 포함되어 있으면 1번 매개변수(선택자)를 뒤집는다
-- 함수 명단
-- Duel.SelectMatchingCard(선택자,필터,시점,자신위치,상대위치,최소매수,최대매수,예외)
-- Duel.SelectTarget(선택자,필터,시점,자신위치,상대위치,최소매수,최대매수,예외) -> 덱에서 대상지정하지는 않으니 사실상 묘지 전용
-- Duel.SelectFusionMaterial(선택자,)
-- 일단 가능한것만 해두자
local dsmc=Duel.SelectMatchingCard
function Duel.SelectMatchingCard(sel,fil,pos,sloc,oloc,min,max,...)
	--선택자(sel)가 자신의 덱을 확인하는 경우에 적용되어야 함. sel==pos이고 sloc이거나 sel!=pos이고 oloc이어야 함.
	if sel==pos and bit.band(sloc,LOCATION_DECK)==LOCATION_DECK then
		if Duel.IsPlayerAffectedByEffect(sel,EFFECT_SELECTBY_OPPO) then 
			sel=1-sel 
			local g=Duel.GetMatchingGroup(fil,pos,sloc,oloc,...)
			Duel.ConfirmCards(sel,g)
		end
	end
	if not sel==pos and bit.band(oloc,LOCATION_DECK)==LOCATION_DECK then
		if Duel.IsPlayerAffectedByEffect(sel,EFFECT_SELECTBY_OPPO) then 
			sel=1-sel 
			local g=GetMatchingGroup(fil,pos,sloc,oloc,...)
			Duel.ConfirmCards(sel,g)
		end
	end
	return dsmc(sel,fil,pos,sloc,oloc,min,max,...)
end
local gsl=Group.Select
function Group.Select(g,sel,m,x,els)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) and Duel.IsPlayerAffectedByEffect(sel,EFFECT_SELECTBY_OPPO) then
		sel=1-sel 
		Duel.ConfirmCards(sel,g)
	end
	return gsl(g,sel,m,x,els)
end
local ssg=aux.SelectUnselectGroup
function Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) and Duel.IsPlayerAffectedByEffect(seltp,EFFECT_SELECTBY_OPPO) then
		seltp=1-seltp 
		Duel.ConfirmCards(seltp,g)
	end
	
	return ssg(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)	
end

function Card.IsPreviousControler(c,p)
	local tp=c:GetPreviousControler()
	if tp==p then return true end
	return false
end




cyan.PlayerCounter={
--플레이어 카운터 등록
--카운터(재앙의 전이)
[0x1]={0,0},
--앵화난무 스택
[0x2]={0,0},
}

function Duel.AddPlayerCounter(p,code,ct)
	if not cyan.PlayerCounter[code] then
		Debug.Message("Duel.AddPlayerCounter : Invaild pcounter code.")
		return 0
	else
		cyan.PlayerCounter[code][p+1]=cyan.PlayerCounter[code][p+1]+ct
		return ct
	end
end
function Duel.GetPlayerCounter(p,code)
	if not cyan.PlayerCounter[code] then
		Debug.Message("Duel.GetPlayerCounter : Invaild pcounter code.")
		return 0
	else
		return cyan.PlayerCounter[code][p+1]
	end	
end
function Duel.RemovePlayerCounter(p,code,ct)
	if not cyan.PlayerCounter[code] then
		Debug.Message("Duel.RemovePlayerCounter : Invaild pcounter code.")
		return 0
	else
		if cyan.PlayerCounter[code][p+1]<ct then ct=cyan.PlayerCounter[code][p+1] end
		cyan.PlayerCounter[code][p+1]=cyan.PlayerCounter[code][p+1]-ct
		return ct
	end	
end
function Duel.SetPlayerCounter(p,code,ct)
	if not cyan.PlayerCounter[code] then
		Debug.Message("Duel.RemovePlayerCounter : Invaild pcounter code.")
		return 0
	else
		cyan.PlayerCounter[code][p+1]=ct
		return ct
	end	
end
cyan.CheckTargetRange={0,0}
local estr=Effect.SetTargetRange
function Effect.SetTargetRange(e,s,o)
	cyan.CheckTargetRange={s,o}
	estr(e,s,o)
end

local dregeff=Duel.RegisterEffect
function Duel.RegisterEffect(e,p)
	if bit.band(e:GetProperty(),EFFECT_FLAG_PLAYER_TARGET)==EFFECT_FLAG_PLAYER_TARGET then
		if cyan.CheckTargetRange[1]==1 and cyan.CheckTargetRange[2]==0 and Duel.GetPlayerCounter(p,0x1)>0
			and Duel.SelectYesNo(p,683,Duel.GetPlayerCounter(p,0x1)) then
			e:SetTargetRange(0,1)
			Duel.RemovePlayerCounter(p,0x1,1)
		end
		if cyan.CheckTargetRange[1]==0 and cyan.CheckTargetRange[2]==1 and Duel.GetPlayerCounter(1-p,0x1)>0
			and Duel.SelectYesNo(1-p,683,Duel.GetPlayerCounter(p,0x1)) then
			e:SetTargetRange(1,0)
			Duel.RemovePlayerCounter(1-p,0x1,1)
		end		
		local s=cyan.CheckTargetRange[1]
		local o=cyan.CheckTargetRange[2]
		--플라워힐용 패에넣을수없다 부여 무효화(추후 플라워힐 유틸이 만들어지면 이동)	
		local ecode=e:GetCode()
		if ecode==EFFECT_CANNOT_TO_HAND or ecode==EFFECT_CANNOT_DRAW then
			if Duel.IsPlayerAffectedByEffect(p,FLOWERHILL_THIMMUNE) 
				and cyan.CheckTargetRange[1]==1 then 
				s=0
			end
			if Duel.IsPlayerAffectedByEffect(1-p,FLOWERHILL_THIMMUNE) 
				and cyan.CheckTargetRange[2]==1 then 
				o=0
			end	
			e:SetTargetRange(s,o)
		end
	end
	dregeff(e,p)
end

local dds=Duel.Destroy
function Duel.Destroy(g,r)
	if type(g)=="Card" then
		local tc=g
		g=Group.CreateGroup()
		g:AddCard(tc)
	end
	if Duel.IsPlayerAffectedByEffect(0,EFFECT_DESTROY_CANCEL) then
		local og=g:Filter(Card.IsControler,nil,0)
		g:Sub(og)
	end
	if Duel.IsPlayerAffectedByEffect(1,EFFECT_DESTROY_CANCEL) then
		local sg=g:Filter(Card.IsControler,nil,1)
		g:Sub(sg)
	end
	return dds(g,r)
end

local drm=Duel.Remove
function Duel.Remove(g,pos,r)
	if type(g)=="Card" then
		local tc=g
		g=Group.CreateGroup()
		g:AddCard(tc)
	end
	if Duel.IsPlayerAffectedByEffect(0,EFFECT_REMOVE_CANCEL) then
		local og=g:Filter(Card.IsControler,nil,0)
		g:Sub(og)
	end
	if Duel.IsPlayerAffectedByEffect(1,EFFECT_REMOVE_CANCEL) then
		local sg=g:Filter(Card.IsControler,nil,1)
		g:Sub(sg)
	end
	return drm(g,pos,r)
end

local dss=Duel.SpecialSummon
function Duel.SpecialSummon(c,st,sp,fp,tf,tf1,...)
	if type(c)=="Card" then
		if c:IsHasEffect(EFFECT_OPPO_FIELD_FUSION) and st==SUMMON_TYPE_FUSION then
			if sp==c:GetControler() then
				fp=1-sp
			end
		end	
	end
	if type(c)=="Group" then
		local tc=c:GetFirst()
		local g=Group.CreateGroup()
		while tc do
			if tc:IsHasEffect(EFFECT_OPPO_FIELD_FUSION) and st==SUMMON_TYPE_FUSION then
				if sp==tc:GetHandler():GetControler() then
					fp=1-sp
					g:AddCard(tc)
					c:RemoveCard(tc)
				end
			end	
			tc=c:GetNext()
		end
	end
	if g and g:GetCount()>0 then
		dss(g,st,sp,fp,tf,tf1,...)
	end
	return dss(c,st,sp,fp,tf,tf1,...)
end

local dcc=Duel.ConfirmCards
function Duel.ConfirmCards(p,g)
	if type(g)=="number" then
		return dcc(g,p)
	end
	return dcc(p,g)
end

--점술
function Duel.Scry(e,p,ct)
	if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<ct then return false end
	local g=Duel.GetDecktopGroup(p,ct)
	Duel.ConfirmCards(p,g)
	if Duel.SelectYesNo(p,683) then
		if g:GetCount()>1 then
			local g1=g:Select(p,1,ct)
			g:Sub(g1)
			while g:GetCount()>0 do
				local g2=g:Select(p,1,1)
				Duel.MoveSequence(g2:GetFirst(),1)
				g:Sub(g2)
			end
			Duel.SortDecktop(p,p,g1:GetCount())
		else
			
		end
	else
		Duel.SortDecktop(p,p,ct)
		for i=1,ct do
			local tg=Duel.GetDecktopGroup(p,1)
			Duel.MoveSequence(tg:GetFirst(),1)
		end
	end
end
function Duel.IsPlayerCanScry(p,ct)
	return Duel.GetFieldGroupCount(p,LOCATION_DECK,0)>=ct
end

yusha_token_codes={3285553,3285554,3285555,3285556,3285557,3285558,3285559,3285560,3285561,3285562,3285563,3285564,3285565,3285566,3285567,3285568}
local dct=Duel.CreateToken
function Duel.CreateToken(p,code)
	if code==3285552 then
		code=yusha_token_codes[Duel.GetRandomNumber(1,#yusha_token_codes)]
	end
	return dct(p,code)
end


function Synchro.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	--Execute the operation function of the Synchro Monster's "EFFECT_MATERIAL_CHECK" effect, if it exists ("Cupid Pitch")
	local mat_check_eff=c:IsHasEffect(EFFECT_MATERIAL_CHECK)
	if mat_check_eff then
		local mat_check_op=mat_check_eff:GetOperation()
		if mat_check_op then mat_check_op(mat_check_eff,c) end
	end
	--Use up the count limit of any "EFFECT_SYNCHRO_MAT_FROM_HAND" effect in the material group ("Revolution Synchron")
	for mc in g:Iter() do
		local handmatfilter=mc:IsHasEffect(EFFECT_SYNCHRO_MAT_FROM_HAND)
		if handmatfilter and handmatfilter:GetValue(handmatfilter,mc,c) then
			handmatfilter:UseCountLimit(tp)
		end
	end
	local tg=g:Filter(Auxiliary.TatsunecroFilter,nil)
	if #tg>0 then
		Synchro.Send=2
		for tc in aux.Next(tg) do tc:ResetFlagEffect(3096468) end
	end
	g=g:Filter(cyan.NoGraveSynChk,nil)
	if Synchro.Send==1 then
		Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO+REASON_RETURN)
	elseif Synchro.Send==2 then
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==3 then
		Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==4 then
		Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==5 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==6 then
		Duel.Destroy(g,REASON_MATERIAL+REASON_SYNCHRO)
	else
		Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	end
	Synchro.Send=0
	Synchro.CheckAdditional=nil
	g:DeleteGroup()
end
function cyan.NoGraveSynChk(c)
	return not c:IsHasEffect(101270019)
end










function Card.AddStoryTellerAttribute(c,tc)
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_MONSTER+TYPE_EFFECT)
	e1:SetReset(RESET_EVENT+0x47c0000)
	c:RegisterEffect(e1,true)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e3,true)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(500)
	c:RegisterEffect(e4,true)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	e5:SetValue(500)
	c:RegisterEffect(e5,true)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CHANGE_RACE)
	e6:SetValue(RACE_FAIRY)
	c:RegisterEffect(e6,true)
	local e7=e1:Clone()
	e7:SetCode(EFFECT_CHANGE_LEVEL)
	e7:SetValue(3)
	c:RegisterEffect(e7,true)	
end

Debug.Message("Cyan.lua Version 23/09/14 loaded.")
pcall(dofile,"repositories/OricaPack/script/orica_constant.lua")
pcall(dofile,"repositories/OricaPack/script/orica_constants.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_utility.lua")
pcall(dofile,"repositories/OricaPack/script/key_system.lua")
pcall(dofile,"repositories/OricaPack/script/gift_system.lua")
--pcall(dofile,"repositories/OricaPack/script/proc_xyz_additional.lua") -- B10: line 28 syntax error (incomplete if). pcall이 파싱 실패를 먹어 주석 해제해도 조용히 무시됐을 것
-- pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/interduo.lua")
pcall(dofile,"repositories/OricaPack/script/proc_access.lua")
pcall(dofile,"repositories/OricaPack/script/proc_pairing.lua")
if not TYPE_UNLOCKED or TYPE_KEY~=0x8 then
	Debug.Message("ORICA: orica_constants.lua 로드 실패 또는 값 불일치")
end
pcall(dofile,"repositories/OricaPack/script/bossraid_battle.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/clocktower.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/starsnow.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/nightmist.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/libertylane.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/raimei.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/draco.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/fragmata.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/celestia.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/diletant.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/companion.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/saintmirage.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/amass.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/furioso.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/sakura.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/emberfox.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/unity.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/radiant.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/mystery.lua")
pcall(dofile,"repositories/OricaPack/script/cyan_themeutils/foregone.lua")