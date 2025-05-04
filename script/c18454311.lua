--매크로 드레인
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DAMAGE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTR("O","O")
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTR("M","M")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FC","S")
	e4:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e4,4,"NO")
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		s[2]={}
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_REMOVE)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=MakeEff(c,"FC")
		ge3:SetCode(EVENT_STARTUP)
		ge3:SetOperation(s.gop3)
		Duel.RegisterEffect(ge3,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[2]={}
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local code=tc:GetOriginalCodeRule()
		s[2][code]=true
		tc=eg:GetNext()
	end
end
function s.gop3(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if not s[p] then
			local token=Duel.CreateToken(p,id)
			token:Type(0)
			s[p]=token
		end
	end
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000)
	end
	Duel.PayLPCost(tp,1000)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function s.ofil1(c,tp)
	return (c:IsSetCard("매크로") or c:IsSetCard("드레인"))
		and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"S")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil,tp)
		local tc=g:GetFirst()
		if tc and Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true) and tc:IsSetCard("드레인") then
			Duel.Damage(tp,1000,REASON_EFFECT)
		end
	end
end
function s.con2(e)
	local res={}
	for p=0,1 do
		local tc=s[p]
		local eset={tc:IsHasEffect(EFFECT_TO_GRAVE_REDIRECT)}
		for _,te in ipairs(eset) do
			if te:GetValue()==LSTN("R") then
				local tg=te:GetTarget()
				if not tg or tg(te,tc) then
					res[p]=true
				end
			end
		end
	end
	return res[0] and res[1]
end
function s.tar2(e,c)
	for code,_ in pairs(s[2]) do
		if c:IsOriginalCodeRule(code) then
			return true
		end
	end
	return false
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local res={}
	for p=0,1 do
		local tc=s[p]
		local eset={tc:IsHasEffect(EFFECT_TO_GRAVE_REDIRECT)}
		for _,te in ipairs(eset) do
			if te:GetValue()==LSTN("R") then
				local tg=te:GetTarget()
				if not tg or tg(te,tc) then
					res[p]=true
				end
			end
		end
	end
	if res[0] and res[1] then
		local rc=re:GetHandler()
		for code,_ in pairs(s[2]) do
			if rc:IsOriginalCodeRule(code) then
				return true
			end
		end
	end
	return false
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end