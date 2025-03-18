--功力狼 盔窍瘤遏
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTf","S")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_RECOVER)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTf","S")
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetCL(1)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]={0,0,0,0}
		s[1]={0,0,0,0}
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_TO_GRAVE)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=MakeEff(c,"FC")
		ge3:SetCode(EVENT_REMOVE)
		ge3:SetOperation(s.gop3)
		Duel.RegisterEffect(ge3,0)
		local ge4=MakeEff(c,"FC")
		ge4:SetCode(EVENT_MOVE)
		ge4:SetOperation(s.gop4)
		Duel.RegisterEffect(ge4,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local ct1,ct2=s[p][3],s[p][4]
		s[p]={ct1,ct2,0,0}
	end
end
function s.gofil2(c,tp)
	return c:IsControler(tp) and c:IsSetCard("功力")
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local ct=eg:FilterCount(s.gofil2,nil,p)
		if ct>0 then
			s[p][3]=s[p][3]+1
		end
	end
end
function s.gop3(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local ct=eg:FilterCount(s.gofil2,nil,p)
		if ct>0 then
			s[p][4]=s[p][4]+1
		end
	end
end
function s.gofil4(c,tp)
	return c:IsControler(tp) and c:IsSetCard("功力") and c:IsLoc("G") and c:IsPreviousLocation(LSTN("R"))
end
function s.gop4(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local ct=eg:FilterCount(s.gofil4,nil,p)
		if ct>0 then
			s[p][3]=s[p][3]+1
		end
	end
end
function s.ofil1(c)
	return c:IsSetCard("功力") and not c:IsCode(id) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_NORMAL) and not tc:IsSummonType(SUMMON_TYPE_TRIBUTE) and tc:IsLevelAbove(5) and tc:IsFaceup()
		and tc:IsSummonPlayer(tp) and tc:IsLoc("M")
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_NORMAL) and not tc:IsSummonType(SUMMON_TYPE_TRIBUTE) and tc:IsFaceup()
		and tc:IsSummonPlayer(tp) and tc:IsLoc("M") then
		Duel.SetTargetCard(eg)
	end
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,tc:GetLevel()*100)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Recover(tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if s[tp][1]>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if s[tp][2]>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end