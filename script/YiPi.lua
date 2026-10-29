yipi=yipi or {} 
Yipi=yipi
YiPi=yipi


RACE_600=0x2000000
CODE_111310014=1012430111
EFFECT_CHEMICAL=101236010
EVENT_BLEND=101236000
CATEGORY_CHEMICAL=0x100000000
--리피트 라이프 변동 관련
local dr=Duel.Recover
function Duel.Recover(tp,val,r)
	val=yipi.LpRecoverCheck(tp,val)
	dr(tp,val,r)
	return val
end
local dp=Duel.PayLPCost
function Duel.PayLPCost(tp,val)
	val=yipi.LpPayCheck(tp,val)
	dp(tp,val)
	return val
end

--리피트 라이프 회복 체크
function yipi.LpRecoverCheck(tp,val)
	if val>=1000 then
		local d=math.floor(val/1000)
		--앨리스 드로우
		if Duel.IsPlayerAffectedByEffect(tp,101239000) then
			if Duel.Draw(tp,d,REASON_EFFECT) then return 0 end
		--윈트 묘지 회수
		elseif Duel.IsPlayerAffectedByEffect(tp,101239001)
			and Duel.IsExistingMatchingCard(yipi.rphfilter,tp,LOCATION_GRAVE,0,d,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,yipi.rphfilter,tp,LOCATION_GRAVE,0,d,d,nil)
			if Duel.SendtoHand(g,nil,REASON_EFFECT) then return 0 end
		--셀리아 제외 회수
		elseif Duel.IsPlayerAffectedByEffect(tp,101239002)
			and Duel.IsExistingMatchingCard(nil,tp,LOCATION_REMOVED,0,d,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_REMOVED,0,d,d,nil)
			if Duel.SendtoDeck(g,nil,2,REASON_EFFECT) then return 0 end
		else return val
		end
	else return val
	end
end
--리피트 라이프 지불 체크
function yipi.LpPayCheck(tp,val)
	if val>=1000 then
		local d=math.floor(val/1000)
		--앨리스 상대 드로우
		if Duel.IsPlayerAffectedByEffect(tp,101239000) then
			if Duel.Draw(1-tp,d,REASON_EFFECT) then return 0 end
		--윈트 핸드 디스
		elseif Duel.IsPlayerAffectedByEffect(tp,101239001)
			and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,d,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			if Duel.DiscardHand(tp,Card.IsDiscardable,d,d,REASON_EFFECT+REASON_DISCARD,nil) then return 0 end
		--셀리아 덱탑 제외
		elseif Duel.IsPlayerAffectedByEffect(tp,101239002)
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,d,nil) then
			local g=Duel.GetDecktopGroup(tp,d)
			Duel.DisableShuffleCheck()
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then return 0 end
		else return val
		end
	else return val
	end
end
function yipi.rphfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x61a)
end

function yipi.DexToHex(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)
	local et=e:GetCode()
	if et==EVENT_REMOVE then
		local egc=e:GetCondition()
		if type(egc)=="function" then e:SetCondition(yipi.flipcon(egc)) 
		else
			e:SetCondition(yipi.flipcon(egc))
		end
	end	
end
function yipi.flipcon(egc)
	return
		function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			if re then
				local ec=re:GetHandler()
					if (ec:GetCode()==101235001 or ec:GetCode()==101235004 or ec:GetCode()==101235006 or ec:GetCode()==101235008) then return false end
			end		
			if egc==nil then return true end
			local ec=re:GetHandler()
			if type(egc)=="function" then
				return egc(e,tp,eg,ep,ev,re,r,rp)
			else
				return egc
			end
		end
end
function Duel.GetDeckbottomGroup(tp,ct)
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	local sg=Duel.GetDecktopGroup(tp,dc-ct)
	g:Sub(sg)
	return g
end

function yipi.AddChemical(c,cm)
   local ct=0
   local le={c:IsHasEffect(EFFECT_CHEMICAL)}
   for _,te in pairs(le) do
      ct=ct+1
   end
   if ct>3 then
      ct=3
      local chs={0,0,0}
      local le1={c:IsHasEffect(EFFECT_CHEMICAL)}
      local ct1=0
      for _,te in pairs(le1) do
         if ct1~=0 then
            chs[ct1]=te:GetValue()
         end
         te:Reset()
         ct1=ct1+1
      end      
      local e1=Effect.CreateEffect(c)
      e1:SetDescription(aux.Stringid(101236009,chs[1]))
      e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CHEMICAL)
      e1:SetValue(chs[1])
      e1:SetReset(RESET_EVENT+RESETS_STANDARD)
      c:RegisterEffect(e1,true)
      local e2=Effect.CreateEffect(c)
      e2:SetDescription(aux.Stringid(101236009,4+chs[2]))
      e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_CHEMICAL)
      e2:SetValue(chs[2])
      e2:SetReset(RESET_EVENT+RESETS_STANDARD)
      c:RegisterEffect(e2,true)   
      local e3=Effect.CreateEffect(c)
      e3:SetDescription(aux.Stringid(101236009,8+chs[3]))
      e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e3:SetType(EFFECT_TYPE_SINGLE)
      e3:SetCode(EFFECT_CHEMICAL)
      e3:SetValue(chs[3])
      e3:SetReset(RESET_EVENT+RESETS_STANDARD)
      c:RegisterEffect(e3,true)      
   end
   local e1=Effect.CreateEffect(c)
   e1:SetDescription(aux.Stringid(101236009,cm+(ct*4)))
   e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
   e1:SetType(EFFECT_TYPE_SINGLE)
   e1:SetCode(EFFECT_CHEMICAL)
   e1:SetValue(cm)
   e1:SetReset(RESET_EVENT+RESETS_STANDARD)
   c:RegisterEffect(e1,true)
end

function yipi.SelectChemical(player,card)
	local sel=Duel.SelectOption(player,aux.Stringid(101236000,0),aux.Stringid(101236000,1),aux.Stringid(101236000,2),aux.Stringid(101236000,3))
	yipi.AddChemical(card,sel)
end

function yipi.GetChemical(c,cm)
	local ct=0
	local le={c:IsHasEffect(EFFECT_CHEMICAL)}
	for _,te in pairs(le) do
		if te:GetValue()==cm then ct=ct+1 end
	end
	return ct
end

function yipi.Blend(c,tp)
   local ct=101236013
   local mc=0
   while ct<101236022 do
      if yipi.DrinkRecipe[ct][1]==yipi.GetChemical(c,0) and yipi.DrinkRecipe[ct][2]==yipi.GetChemical(c,1)
         and yipi.DrinkRecipe[ct][3]==yipi.GetChemical(c,2) and yipi.DrinkRecipe[ct][4]==yipi.GetChemical(c,3) then mc=ct end
      ct=ct+1
   end
   if mc>0 then
      if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
      local token=Duel.CreateToken(tp,mc)
      if not Duel.IsPlayerCanSpecialSummonMonster(tp,mc,0,token:GetType(),token:GetAttack(),token:GetDefense(),token:GetLevel(),token:GetRace(),token:GetAttribute()) then return end
      Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
      Duel.SpecialSummonComplete()
      local le1={c:IsHasEffect(EFFECT_CHEMICAL)}
      for _,te in pairs(le1) do
         te:Reset()
      end
     Duel.RaiseEvent(token,EVENT_BLEND,nil,REASON_EFFECT,tp,tp,nil)
     Duel.RaiseSingleEvent(token,EVENT_BLEND,nil,REASON_EFFECT,tp,tp,nil)
   end
end

yipi.DrinkRecipe={
--거트 펀치
[101236013]={0,1,0,1},
--블루 페어리
[101236014]={1,0,0,1},
--슈가 러쉬
[101236015]={1,0,1,0},
--배드 터치
[101236016]={0,1,1,1},
--브랜티니
[101236017]={2,0,1,0},
--수플렉스
[101236018]={0,2,0,1},
--마스블라스트
[101236019]={0,2,1,1},
--머큐리블라스트
[101236020]={1,1,1,1},
--문블라스트
[101236021]={2,0,1,1},
}

pcall(dofile,"repositories/OricaPack/script/Hunter.lua")