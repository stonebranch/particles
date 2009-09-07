package particles;

enum EmitterType {
	Custom( vxMin : Float , vxMax : Float , vyMin : Float , vyMax : Float , vzMin : Float , vzMax : Float , lifetime : Float );
	Pour( spread : Float , lifetime : Float );
}
/*
man vill ju kunna bestämma riktning och spridning typ
och antal och livslängd
och en effekt typ att den alphar ut, eller så
byter färg kanske
hastighet
*/

#if flash10
import particles.Particles; // Only to "hack" the Vector into an Array
#end

class Emitter {
	
	public var x : Float;
	public var y : Float;
	public var z : Float;

	var _type : EmitterType;
	var _maxParticles : Int;
	var _particlesPerFrame : Int;
	var _pool : ParticlePool;
	var _particles : Array<Particle>;
	var _count : Int;
	var _pos : Int;
	var _lifetimes : Hash<Float>;
	
	public function new( type : EmitterType , particle : Particle , maxParticles : Int , particlesPerFrame : Int = 1 ) {
		_type = type;
		_maxParticles = maxParticles;
		_particlesPerFrame = particlesPerFrame;
		var particle = particle.clone();
		particle.onRemove = removeParticle;
		_pool = new ParticlePool( particle , maxParticles );
		_particles = new Array<Particle>( #if flash10 maxParticles , true #end );
		_lifetimes = new Hash<Float>();
		_count = _pos = 0;
	}
	
	public inline function position( x , y , z ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function emit() {
		if( _count < _maxParticles ) {
			for( i in 0..._particlesPerFrame ) {
				var p = _pool.retrieve();
				p.x = x;
				p.y = y;
				p.z = z;
				p.active = true;
				switch( _type ) {
					case Custom( vxMin , vxMax , vyMin , vyMax , vzMin , vzMax , lifetime ):
						p.vx = vxMin + Math.random() * ( vxMax - vxMin );
						p.vy = vyMin + Math.random() * ( vyMax - vyMin );
						p.vz = vzMin + Math.random() * ( vzMax - vzMin );
						_lifetimes.set( Std.string( p.id ) , lifetime );
					case Pour( spread , lifetime ):
						p.vx = ( spread * -.5 ) + Math.random() * ( spread + spread );
						_lifetimes.set( Std.string( p.id ) , lifetime );
				}
				_particles[ _count++ ] = p;
				trace( "Added a particle " + p.id  + " lt: " + _lifetimes.get( Std.string( p.id ) )  + " now has " + _count );
				if( _count >= _maxParticles )
					break;
			}
		}

		for( p in _particles ) {
	        if( p == null ) 
	        	continue;
			checkParticle( p );
		}

		_pos = 0;
		return this;
	}
	
	inline function checkParticle( p : Particle ) {
		_lifetimes.set( Std.string( p.id ) , _lifetimes.get( Std.string( p.id ) ) - 1 );
		var lt = _lifetimes.get( Std.string( p.id ) );
        if( lt < 0 )
			removeParticle( p );
	}
	
	inline function removeParticle( p ) {
		_pool.release( p );
		_particles[_count] = null;
       	_count--;
       	trace( "Removed a particle " + p.id  + " lt: " + _lifetimes.get( Std.string( p.id ) ) + " now has " + _count );
	}
	
	public function hasNext() {
		return _pos < _count;
	}
	
	public function next() {
		return _particles[ _pos++ ];
	}

}