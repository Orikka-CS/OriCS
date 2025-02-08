--예언하는 음유사신
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
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
function s.nfil1(c)
	return c:IsSetCard("음유사신") and c:IsFaceup()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IEMCard(s.nfil1,tp,"O",0,1,nil) or
		(Duel.GetFieldGroupCount(tp,LSTN("G"),0)>=25 and Duel.GetFieldGroupCount(tp,0,LSTN("G"))>=25))
		and rp~=tp and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.tfil1(c)
	return c:IsCode(66429798)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s[tp]:FilterCount(Card.IsAbleToGrave,nil)==5
			and s[1-tp]:FilterCount(Card.IsAbleToGrave,nil)==5
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,10,PLAYER_ALL,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if s[tp]:FilterCount(Card.IsAbleToGrave,nil)==5
		and s[1-tp]:FilterCount(Card.IsAbleToGrave,nil)==5 then
		local sg=Group.CreateGroup()
		sg:Merge(s[tp])
		sg:Merge(s[1-tp])
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end