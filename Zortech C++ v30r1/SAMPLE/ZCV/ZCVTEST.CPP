class Root{};
class Another
{
	Another *anp;	
};
class Derived1: virtual public Root, private Another
{
protected:
	Root *rp;
};
class Derived2: virtual public Root
{
friend class Derived1;
};
class Top: public Derived1, public Derived2
{
private:
	Root &rr;
public:
	Another one;
};
