--골도이드 블론드
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCL(1,id)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCL(1,{id,2})
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]=true
		s[1]=true
		local ge1=MakeEff(c,"F")
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetValue(s.gval1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
s.listed_names={18454259}
function s.gvfil1(c)
	return not (c:IsLevel(5) or c:IsRank(5) or c:IsLevel(10) or c:IsRank(10))
end
function s.gval1(e,c)
	local tp=c:GetControler()
	if c:GetMaterial():IsExists(s.gvfil1,1,nil) and not c:IsType(TYPE_RITUAL) then
		s[tp]=false
	end
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	s[0]=true
	s[1]=true
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return s[tp] and Duel.GetLocCount(tp,"M")>0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTR(0xff,0xff)
	e1:SetTarget(aux.TargetBoolFunction(s.gvfil1))
	e1:SetValue(s.oval11)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_ORDER_MATERIAL)
	Duel.RegisterEffect(e4,tp)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_MODULE_MATERIAL)
	Duel.RegisterEffect(e5,tp)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_SQUARE_MATERIAL)
	Duel.RegisterEffect(e6,tp)
	--local e7=e1:Clone()
	--e7:SetCode(EFFECT_CANNOT_BE_BEYOND_MATERIAL)
	--Duel.RegisterEffect(e7,tp)
	local e8=e1:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_DELIGHT_MATERIAL)
	Duel.RegisterEffect(e8,tp)
	local e9=e1:Clone()
	e9:SetCode(EFFECT_UNRELEASABLE_SUM)
	Duel.RegisterEffect(e9,tp)
end
function s.oval11(e,c)
	if not c then
		return false
	end
	return c:IsControler(e:GetHandlerPlayer())
end
function s.tfil2(c)
	return c:IsCode(18454259) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTR("M",0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"골도이드"))
	e1:SetValue(s.oval31)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.oval31(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end