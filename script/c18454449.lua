--sparkle.exe: Even the bugs can make a show
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSequenceProcedure(c,nil,s.pfil1,1,99,s.pfil2,1,99,aux.TRUE,1,99)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","M")
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	WriteEff(e2,2,"NO")
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetCondition(s.gcon1)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.pfil1(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard("sparkle.exe")
end
function s.pfil2(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsRace(RACE_INSECT|RACE_AQUA|RACE_WINGEDBEAST)
end
function s.gnfil1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LSTN("D"))
end
function s.gcon1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPhase(PHASE_DRAW) or Duel.IsPhase(PHASE_DAMAGE) then
		return false
	end
	local v=0
	if eg:IsExists(s.gnfil1,1,nil,0) then v=v+1 end
	if eg:IsExists(s.gnfil1,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	if ev<=1 or rp==tp then
		return false
	end
	local cp=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return cp==tp
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
	Duel.ConfirmCards(1-tp,c)
end
function s.tfil1(c)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return ev==1-tp or ev==PLAYER_ALL
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTR("D","D")
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end