--음유사신 스피넬
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local xe1=Xyz.AddProcedure(c,nil,8,3,s.pfil1,aux.Stringid(id,2),3,s.pop1)
	xe1:SetD(id,0)
	local xe2=Xyz.AddProcedure(c,nil,12,2)
	xe2:SetD(id,1)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOGRAVE)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","M")
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
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
function s.pfil1(c,tp,xc)
	return c:IsSummonCode(xc,SUMMON_TYPE_XYZ,tp,66429798) and c:IsFaceup()
end
function s.pop1(e,tp,chk,mc)
	if chk==0 then
		return s[tp]:FilterCount(Card.IsAbleToGraveAsCost,nil)==5
			and s[1-tp]:FilterCount(Card.IsAbleToGraveAsCost,nil)==5
			and Duel.GetFlagEffect(tp,id-10000)==0
	end
	local g=Group.CreateGroup()
	g:Merge(s[tp])
	g:Merge(s[1-tp])
	Duel.SendtoGrave(g,REASON_COST)
	Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s[tp]:FilterCount(Card.IsAbleToGrave,nil)==5
			and s[1-tp]:FilterCount(Card.IsAbleToGrave,nil)==5
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,10,PLAYER_ALL,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if s[tp]:FilterCount(Card.IsAbleToGrave,nil)==5
		and s[1-tp]:FilterCount(Card.IsAbleToGrave,nil)==5 then
		local sg=Group.CreateGroup()
		sg:Merge(s[tp])
		sg:Merge(s[1-tp])
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tfil2(c,e,tp)
	return ((c:IsSetCard("음유사신") and c:IsType(TYPE_SPELL+TYPE_TRAP)) or (c:IsAttack(2500) and c:IsDefense(2500))
		and c:IsAbleToHand() and c:IsLoc("DG"))
		or (Duel.GetFieldGroupCount(tp,LSTN("G"),0)>=25 and Duel.GetFieldGroupCount(tp,0,LSTN("G"))>=25
			and c:IsCode(18454268,3149401,99217226,58931850) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and ((c:IsLoc("D") and Duel.GetLocCount(tp,"M")>0)
				or (c:IsLoc("E") and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
			)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"DGE",0,1,nil,e,tp)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"DG")
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"DE")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"DGE",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,
			function(sc)
				return Duel.GetFieldGroupCount(tp,LSTN("G"),0)>=25 and Duel.GetFieldGroupCount(tp,0,LSTN("G"))>=25
					and sc:IsCode(18454268,3149401,99217226,58931850) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
					and ((sc:IsLoc("D") and Duel.GetLocCount(tp,"M")>0)
						or (sc:IsLoc("E") and Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0))
			end,
			function(sc)
				return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,3)
		)
	end
end