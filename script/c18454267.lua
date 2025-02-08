--음유사신 리제네시스
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
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FTo","G")
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"N")
	WriteEff(e4,2,"TO")
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		s[0]=Group.CreateGroup()
		s[1]=Group.CreateGroup()
		s[0]:KeepAlive()
		s[1]:KeepAlive()
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
s.listed_names={66429798}
function s.gofil1(c)
	return c:GetLocation()~=0
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		s[p]:Sub(s[p]:Filter(s.gofil1,nil))
		local ct=#s[p]
		if ct<5 then
			local g=Group.CreateGroup()
			for i=1,5-ct do
				local token=Duel.CreateToken(p,66429798)
				g:AddCard(token)
			end
			s[p]:Merge(g)
		end
	end
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and s[tp]:FilterCount(Card.IsAbleToGraveAsCost,nil)==5
		and s[1-tp]:FilterCount(Card.IsAbleToGraveAsCost,nil)==5
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Group.CreateGroup()
	g:Merge(s[tp])
	g:Merge(s[1-tp])
	Duel.SendtoGrave(g,REASON_COST)
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTR(1,0)
	e1:SetTarget(s.otar11)
	Duel.RegisterEffect(e1,tp)
end
function s.otar11(e,c)
	return c:GetAttack()%2500~=0 and c:GetDefense()%2500~=0
end
function s.tfil2(c)
	return c:IsAbleToGrave() and (c:IsSetCard("음유사신") or c:IsSetCard(SET_REGENESIS)) and not c:IsCode(id)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN) and Duel.IsTurnPlayer(1-tp)
end