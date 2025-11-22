--백연초의 역마 시가렛
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--fusion
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0xf2b,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end

function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end

--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)~=Duel.GetLP(1-tp) end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local lp1=Duel.GetLP(tp)
	local lp2=Duel.GetLP(1-tp)
	Duel.SetLP(tp,lp2)
	Duel.SetLP(1-tp,lp1)
end

--effect 2
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if s.tg2des(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.tg2drw(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if s.tg2set(e,tp,eg,ep,ev,re,r,rp,0) then ct=ct+1 end
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,1000) and Duel.GetFlagEffect(tp,id)==0 end
	ct=math.min(ct,Duel.GetLP(tp)//1000)
	local t={}
	for i=1,ct do
		t[i]=i*1000
	end
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,cost)
	e:SetLabel(cost/1000)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tg2des(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.tg2drw(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tg2setfilter(c)
	return c:IsSetCard(0xf2b) and c:IsSpellTrap() and c:IsSSetable() and c:IsFaceup()
end

function s.tg2set(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2setfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local opt=0
	local optp=0
	local b1=s.tg2des(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.tg2drw(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.tg2set(e,tp,eg,ep,ev,re,r,rp,0)
	local t
	for i=1,ct do
		local idtable={}
		local desctable={}
		t=1
		if b1 and (opt&1)==0 then
			idtable[t]=1
			desctable[t]=aux.Stringid(id,0)
			t=t+1
		end
		if b2 and (opt&2)==0 then
			idtable[t]=2
			desctable[t]=aux.Stringid(id,1)
			t=t+1
		end
		if b3 and (opt&4)==0 then
			idtable[t]=4
			desctable[t]=aux.Stringid(id,2)
			t=t+1
		end
		if t==1 then return end
		local op=idtable[Duel.SelectOption(tp,table.unpack(desctable)) + 1]
		optp=opt+optp
		opt=opt+op
		if opt==1 or (optp==2 and opt==3) or (optp==4 and opt==5) or ((optp==8 or optp==10) and opt==7) then
			s.op2des(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==2 or (optp==1 and opt==3) or (optp==4 and opt==6) or ((optp==6 or optp==9) and opt==7) then
			s.op2drw(e,tp,eg,ep,ev,re,r,rp)
		elseif opt==4 or (optp==1 and opt==5) or (optp==2 and opt==6) or ((optp==4 or optp==5) and opt==7) then
			s.op2set(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function s.op2des(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

function s.op2drw(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT) 
end

function s.op2set(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2setfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
		Duel.SSet(tp,sg)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		sg:RegisterEffect(e1)
	end
end