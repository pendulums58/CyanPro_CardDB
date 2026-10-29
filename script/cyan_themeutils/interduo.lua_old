
--인터듀오용 코드 체인지 함수

local cgc=Card.GetCode
function Card.GetCode(c)
	--if not c:IsSetCard(0xeff) then return cgc(c) end
	local clist={}
	clist[0]=cgc(c)
	local ct=1
	local le={c:IsHasEffect(EFFECT_ADD_CODE)}
	for _,te in pairs(le) do
		f=te:GetValue()
		clist[ct]=f
		ct=ct+1		
	end
	if #clist==0 then return clist[0]end
	if #clist==1 then return clist[0], clist[1] end
	if #clist==2 then return clist[0], clist[1], clist[2] end
	if #clist==3 then return clist[0], clist[1], clist[2], clist[3] end
	if #clist==4 then return clist[0], clist[1], clist[2], clist[3], clist[4] end
	return cgc(c)
end
local cic=Card.IsCode
function Card.IsCode(c,...)
	local code={...}
	local ccode={c:GetCode()}
	for i=1,#code do 		
		for n=1,#ccode do
			if code[i]==ccode[n] then return true end
		end
	end
	return cic(c,...)
end
function Auxiliary.dncheck(g)
	return g:GetClassCount(cgc)==#g
end